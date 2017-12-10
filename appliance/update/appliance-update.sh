#!/bin/bash
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/metric.functions.sh
. /usr/local/share/appliance/update.functions.sh

# remember start time, either from now or from original calling script parsing --continue
continue=$(test "$1" = "--continue"; echo $?)
if test $continue -eq 0; then
    start_epoch_seconds=$2
    shift 2
    echo "Information: continued appliance-update, original start_epoch: $start_epoch_seconds , now: $(date +%s)"
else
    start_epoch_seconds=$(date +%s)
fi

# ###
# main
# XXX capsule main in function so bash reads whole script at once, see http://stackoverflow.com/questions/21096478/overwrite-executing-bash-script-files
{
    if test $continue -eq 0; then
        # XXX if continue was used, skip already run appliance-update, but set flag to true for restart
        need_appliance_update=true
    else
        simple_metric update_last_call counter "number of seconds since the last update run" $start_epoch_seconds
        check_appliance_update
        need_appliance_update=$(test $? -eq 0 -o \
            -e /app/etc/flags/force.update.appliance && echo true || echo false)
        mute_alerts # ignore job up alerts while update in progress

        if $need_appliance_update; then
            simple_metric appliance_last_update counter "timestamp-epoch-seconds since last update to appliance" $start_epoch_seconds
            if test ! -e /app/appliance; then install -g app -o app -d /app/appliance; fi
            cd /app/appliance
            current_source=$(gosu app git config --get remote.origin.url || echo "")

            if test "$APPLIANCE_GIT_SOURCE" != "$current_source"; then
                # if APPLIANCE_GIT_SOURCE is different to current remote, delete source, re-clone
                sentry_entry "Appliance Update" "Warning: appliance has different upstream sources, will re-clone. Current: \"$current_source\", new: \"$APPLIANCE_GIT_SOURCE\"" warning
                cd /; rm -r /app/appliance; install -g app -o app -d /app/appliance; cd /app/appliance
                gosu app git clone --branch $APPLIANCE_GIT_BRANCH $APPLIANCE_GIT_SOURCE /app/appliance
            fi

            # fetch all updates from origin
            gosu app git fetch -a -p
            if test "$APPLIANCE_GIT_COMMITID" != ""; then
                target="$APPLIANCE_GIT_COMMITID"
            else
                # set target to latest branch commit id
                target=$(gosu app git rev-parse origin/$APPLIANCE_GIT_BRANCH)
            fi
            # get current running commit id
            last_running=$(gosu app git rev-parse HEAD)

            # rewrite minion_id if different to env
            if test "$APPLIANCE_DOMAIN" != "$(cat /etc/salt/minion_id)"; then
                echo "setting minion_id to $APPLIANCE_DOMAIN"
                printf "%s" "$APPLIANCE_DOMAIN" > /etc/salt/minion_id
            fi
            if test "$last_running" != "$target" -o -e /app/etc/flags/force.update.appliance; then
                appliance_status "Appliance Update" "Updating appliance from $last_running to $target"
                if test -e /app/etc/flags/force.update.appliance; then
                    rm /app/etc/flags/force.update.appliance
                fi
                # hard update source
                gosu app git checkout -f $APPLIANCE_GIT_BRANCH
                gosu app git reset --hard origin/$APPLIANCE_GIT_BRANCH
                # appliance code has updated
                touch /app/etc/flags/force.update.ecs
                # call saltstack state.highstate to update appliance
                salt-call state.highstate pillar='{"appliance": {"enabled": true}}' --retcode-passthrough --return appliance
                err=$?
                if test $err -ne 0; then
                    appliance_exit "Appliance Error" "salt-call state.highstate failed with error $err"
                fi
                # save executed commit
                printf "%s" "$target" > /app/etc/tags/last_running_appliance
            fi

            simple_metric appliance_version gauge "appliance_version" 1 \
            "git_rev=\"$(gosu app git -C /app/appliance rev-parse HEAD)\",\
            git_branch=\"$(gosu app git -C /app/appliance rev-parse --abbrev-ref HEAD)\""
            # call new version of self with the original start time
            exec $0 --continue $start_epoch_seconds "$@"
        fi
    fi

    # check for available updates
    apt-get update -y
    
    update_list=$(run_hook appliance-update check)
    
    
    need_service_restart=$( ($need_docker_update || $need_compose_update ||
        $need_postgres_update || $need_letsencrypt_update ||
        $need_appliance_update ) && echo true || echo false)
    echo "Information: Updates available for:"
    
    if ($need_docker_update || $need_compose_update || $need_postgres_update); then
        appliance_status "Appliance Update" "Preparing for Update"
        echo "Info: shutting down appliance, because update of docker:$need_docker_update, compose:$need_compose_update or postgres:$need_postgres_update needs this"
        if $need_docker_update; then
            simple_metric docker_last_update counter "timestamp-epoch-seconds since last update to docker" $start_epoch_seconds
            if test -e /app/etc/flags/force.update.docker; then
                rm /app/etc/flags/force.update.docker
            fi
        fi
        if $need_postgres_update; then
            simple_metric postgres_last_update counter "timestamp-epoch-seconds since last update to postgres" $start_epoch_seconds
            if test -e /app/etc/flags/force.update.postgres; then
                rm /app/etc/flags/force.update.postgres
            fi
        fi
        systemctl stop appliance
        sleep 2 # Wait a little to settle still open connections
        if $need_postgres_update; then
            echo "Warning: prepare postgres update, kill all postgres connections to ecs except ourself"
            gosu app psql ecs -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'ecs' AND pid <> pg_backend_pid();"
        fi
        if $need_compose_update; then
            simple_metric compose_last_update counter "timestamp-epoch-seconds since last update to docker-compose" $start_epoch_seconds
            if test -e /app/etc/flags/force.update.compose; then
                rm /app/etc/flags/force.update.compose
            fi
            pip2 install -U --upgrade-strategy only-if-needed docker-compose
        fi
    fi

    if $need_system_update; then
        appliance_status "Appliance Update" "Unattended System Upgrades"
        simple_metric system_last_update counter "timestamp-epoch-seconds since last system package update" $start_epoch_seconds
        if test -e /app/etc/flags/force.update.system; then
            rm /app/etc/flags/force.update.system
            rm /var/lib/apt/periodic/*
        fi
        # call apt.systemd.daily which calls unattended-upgrades
        /usr/lib/apt/apt.systemd.daily
        # check again to export metric of current updateable packages, should be 0
        check_system_package_update
    fi

    if $need_letsencrypt_update; then
        if test -e /app/etc/flags/force.update.letsencrypt; then
            rm /app/etc/flags/force.update.letsencrypt
        fi
        gosu app dehydrated -c
    fi

    if test -e /var/run/reboot-required; then
        # reboot if needed
        echo "Warning: reboot of system required, rebooting"
        unmute_alerts
        simple_metric update_running_time gauge "number of seconds for a update run" $(($(date +%s) - start_epoch_seconds))
        simple_metric update_last_reboot counter "timestamp-epoch-seconds since update requested reboot" $start_epoch_seconds
        systemctl reboot
        exit 0
    fi

    if $need_service_restart; then
        echo "Information: restarting appliance"
        systemctl restart appliance
    else
        echo "Information: all done, enable access to web service"
        appliance_status --disable
    fi

    simple_metric update_running_time gauge "number of seconds for a update run" $(($(date +%s) - start_epoch_seconds))
    unmute_alerts
    exit 0
}
