#!/bin/bash
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/metric.functions.sh

# remember start time, either from now or from original calling script parsing --continue
continue=$(test "$1" = "--continue"; echo $?)
if test $continue -eq 0; then
    start_epoch_seconds=$2
    shift 2
    echo "Information: continued appliance-update, original start_epoch: $start_epoch_seconds , now: $(date +%s)"
else
    start_epoch_seconds=$(date +%s)
fi


check_system_package_update() {
    local update_count_combined packages_update_count packages_security_count
    local re='^[0-9]+$'
    local system_updates_waiting=false
    # needs up to date package list for proper results
    update_count_combined=$(/usr/lib/update-notifier/apt-check 3>&1 1>&2 2>&3 3>&- )
    packages_update_count=$(echo "$update_count_combined" | sed -r "s/([0-9]+);.*/\1/")
    packages_security_count=$(echo "$update_count_combined" | sed -r "s/[^;]+;([0-9]+).*/\1/")
    if ! [[ $packages_update_count =~ $re ]] ; then
        echo "Warning: Could not get a number of system packages waiting for update, assuming there are update available"
        packages_update_count="Nan"
        system_updates_waiting=true
    elif test $packages_update_count -ne 0; then
        echo "Information: $packages_update_count system packages are waiting for update"
        system_updates_waiting=true
    fi
    if ! [[ $packages_security_count =~ $re ]] ; then
        packages_security_count="Nan"
    fi
    simple_metric system_updates_waiting gauge "number of system packages where a update is available" $packages_update_count
    simple_metric system_security_updates_waiting gauge "number of system packages where a security update is available" $packages_security_count
    $system_updates_waiting
}


check_docker_update(){
    local docker_list docker_old docker_new
    local docker_need_update=false
    # needs up to date package list for proper results
    docker_list=$(apt-cache policy docker-engine -q | grep -E "(Installed|Candidate)")
    docker_old=$(printf "%s" "$docker_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    docker_new=$(printf "%s" "$docker_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$docker_old" != "$docker_new"; then
        echo "Info: New docker-engine available. Installed=$docker_old , Candidate=$docker_new"
        docker_need_update=true
    fi
    $docker_need_update
}


check_compose_update() {
    local compose_need_update=false
    local update_path
    update_path=$(/usr/local/bin/pip2 list -o | grep docker-compose)
    if test $? -eq 0; then
        compose_need_update=true
        echo "Information: docker-compose has update waiting: $update_path"
    fi
    $compose_need_update
}


check_postgres_update(){
    local postgres_list postgres_old postgres_new
    local postgres_need_update=false
    # needs up to date package list for proper results
    postgres_list=$(apt-cache policy postgresql-9.5 -q | grep -E "(Installed|Candidate)")
    postgres_old=$(printf "%s" "$postgres_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    postgres_new=$(printf "%s" "$postgres_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$postgres_old" != "$postgres_new"; then
        echo "Info: New postgresql-9.5 available. Installed=$postgres_old , Candidate=$postgres_new"
        postgres_need_update=true
    fi
    $postgres_need_update
}


check_letsencrypt_update(){
    local RENEW_DAYS valid_until new_metric cert_metric
    local letsencrypt_need_update=false
    RENEW_DAYS="30"
    cert_metric=""
    for i in $(cat /app/etc/dehydrated/domains.txt | sed -r "s/([^ ]+).*/\1/g"); do
        cert_file=/app/etc/dehydrated/certs/$i/cert.pem
        valid_until=$(openssl x509 -in $cert_file -enddate -noout | sed -r "s/notAfter=(.*)/\1/g")
        openssl x509 -in $cert_file -checkend $((RENEW_DAYS * 86400)) -noout
        if test $? -ne 0; then
            letsencrypt_need_update=true
            echo "Information: Letsencrypt certificate for $i needs renewal (valid until $valid_until)"
        fi
        new_metric=$(mk_metric letsencrypt_valid_until gauge "timestamp-epoch-seconds of certificate validity end date" $(date --date="$valid_until" +%s) "domain=\"$i\""; printf "\n")
        cert_metric="$cert_metric
$new_metric"
    done
    metric_export letsencrypt_valid_until "$cert_metric"
    $letsencrypt_need_update
}


check_appliance_update(){
    local current_source target last_running
    local appliance_need_update=true
    if test -e /app/appliance; then
        cd /app/appliance
        current_source=$(gosu app git config --get remote.origin.url || echo "")
        if test "$APPLIANCE_GIT_SOURCE" = "$current_source"; then
            # fetch all updates from origin
            gosu app git fetch -a -p
            if test "$APPLIANCE_GIT_COMMITID" != ""; then
                target="$APPLIANCE_GIT_COMMITID"
            else
                target=$(gosu app git rev-parse origin/$APPLIANCE_GIT_BRANCH)
            fi
            last_running=$(gosu app git rev-parse HEAD)
            if test "$last_running" = "$target"; then
                appliance_need_update=false
            fi
        fi
    fi
    $appliance_need_update
}


check_ecs_update() {
    local current_source target last_running
    local ecs_need_update=true
    if test -e /app/ecs -a ! -e /app/bin/devupdate.sh; then
        cd /app/ecs
        current_source=$(gosu app git config --get remote.origin.url || echo "")
        if test "$ECS_GIT_SOURCE" = "$current_source"; then
            # fetch all updates from origin
            gosu app git fetch -a -p
            if test "$ECS_GIT_COMMITID" != ""; then
                target="$ECS_GIT_COMMITID"
            else
                target=$(gosu app git -C /app/ecs rev-parse origin/$ECS_GIT_BRANCH)
            fi
            last_running=$(cat /app/etc/tags/last_running_ecs 2> /dev/null || echo "invalid")
            if test "$last_running" = "$target"; then
                ecs_need_update=false
            fi
        fi
    fi
    $ecs_need_update
}


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
                # appliance code has updated, we need a rebuild of ecs container
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
    check_system_package_update
    need_system_update=$(test $? -eq 0 -o \
        -e /app/etc/flags/force.update.system && echo true || echo false)
    check_docker_update
    need_docker_update=$(test $? -eq 0 -o \
        -e /app/etc/flags/force.update.docker && echo true || echo false)
    check_compose_update
    need_compose_update=$(test $? -eq 0 -o \
        -e /app/ecs/flags/force.update.compose && echo true || echo false)
    check_postgres_update
    need_postgres_update=$(test $? -eq 0 -o \
        -e /app/etc/flags/force.update.postgres && echo true || echo false)
    check_letsencrypt_update
    need_letsencrypt_update=$(test $? -eq 0 -o \
        -e /app/etc/flags/force.update.letsencrypt && echo true || echo false)
    check_ecs_update
    need_ecs_update=$(test $? -eq 0 -o \
        -e /app/etc/flags/force.update.ecs && echo true || echo false)
    need_service_restart=$( ($need_docker_update || $need_compose_update ||
        $need_postgres_update || $need_letsencrypt_update ||
        $need_appliance_update || $need_ecs_update) && echo true || echo false)
    echo "Information: Updates available for:"
    echo "need_system_update=$need_system_update"
    echo "need_docker_update=$need_docker_update"
    echo "need_compose_update=$need_compose_update"
    echo "need_postgres_update=$need_postgres_update"
    echo "need_letsencrypt_update=$need_letsencrypt_update"
    echo "need_appliance_update=$need_appliance_update"
    echo "need_ecs_update=$need_ecs_update"
    echo "need_service_restart=$need_service_restart"

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
