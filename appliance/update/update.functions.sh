#!/bin/bash

restart_str="#%need_service_restart=true"

bootstrap_source() {
    echo $(cat /app/etc/tags/APPLIANCE_GIT_BOOTSTRAP_SOURCE || echo "") 
}
bootstrap_branch() { 
    echo $(cat /app/etc/tags/APPLIANCE_GIT_BOOTSTRAP_BRANCH || echo "") 
}
running_branch()  {
    echo $(gosu app git -C /app/appliance rev-parse --abbrev-ref HEAD || echo "")
}
running_source() 
{ 
    echo $(gosu app git -C /app/appliance config --get remote.origin.url || echo "")
}
lastused_source()
{
    echo $(cat /app/etc/tags/APPLIANCE_GIT_LASTUSED_SOURCE || echo "") 
}
lastused_branch() 
{ 
    echo $(cat /app/etc/tags/APPLIANCE_GIT_LASTUSED_BRANCH || echo "") 
}

proposed_source()
{
    if test "$APPLIANCE_GIT_SOURCE" != ""; then
        echo "$APPLIANCE_GIT_SOURCE"
    else
        if test "$(lastused_source)" != ""; then
            echo "$(lastused_source)"
        else
            if test "$(bootstrap_source)" != ""; then
                echo "$(bootstrap_source)"
            else
                echo "$(running_source)"
            fi
        fi
    fi
}

proposed_branch()
{
    if test $APPLIANCE_GIT_BRANCH != ""; then
        echo "$APPLIANCE_GIT_BRANCH"
    else
        if test "$(lastused_branch)" != ""; then
            echo "$(lastused_branch)"
        else
            if test "$(bootstrap_branch)" = ""; then
                echo "$(bootstrap_branch)"
            else
                echo "$(running_branch)"
            fi
        fi
    fi
}


check_appliance_update(){
    local current_source proposed_source current_branch proposed_branch
    local targetid lastid
    local appliance_need_update=false
    
    if test -e /app/etc/flags/force.update.appliance; then 
        appliance_need_update=true
        echo "# Information: appliance-update is forced"
    fi
    
    if test -e /app/appliance/.git; then
        cd /app/appliance
        current_source=$(current_source)
        proposed_source=$(proposed_source)
        current_branch=$(current_branch)
        proposed_branch=$(proposed_branch)
        
        if test "$proposed_source" != "$current_source" -o test "$proposed_branch" != "$current_branch"; then
            appliance_need_update=true
            echo "# Warning: source/branch changed; old: $current_source @$current_branch , new: $proposed_source @$proposed_branch"
        else
            # fetch all updates from origin
            gosu app git fetch -a -p
            if test "$APPLIANCE_GIT_COMMITID" != ""; then
                targetid="$APPLIANCE_GIT_COMMITID"
            else
                targetid=$(gosu app git rev-parse origin/$proposed_branch)
            fi
            lastid=$(gosu app git rev-parse HEAD)
            if test "$lastid" != "$targetid"; then
                echo "# Information: LastID: $lastid , TargetID: $targetid"
                appliance_need_update=true
            fi
        fi
    fi

    echo "appliance:do_appliance_update=$($appliance_need_update && echo true || echo false)"
    if $appliance_need_update; then 
        echo "$restart_str"
    fi
}


check_system_update() {
    local update_count_combined packages_update_count packages_security_count
    local re='^[0-9]+$'
    local system_need_update=false
    local system_forced=false

    if test -e /app/etc/flags/force.update.system; then 
        system_need_update=true
        system_forced=true
    fi
    
    # XXX needs up to date package list for proper results
    update_count_combined=$(/usr/lib/update-notifier/apt-check 3>&1 1>&2 2>&3 3>&- )
    packages_update_count=$(echo "$update_count_combined" | sed -r "s/([0-9]+);.*/\1/")
    packages_security_count=$(echo "$update_count_combined" | sed -r "s/[^;]+;([0-9]+).*/\1/")
    if ! [[ $packages_update_count =~ $re ]] ; then
        echo "# Warning: Could not get a number of system packages waiting for update, assuming there are update available"
        packages_update_count="Nan"
        system_need_update=true
    elif test $packages_update_count -ne 0; then
        echo "# Information: $packages_update_count system packages are waiting for update"
        system_need_update=true
    fi
    if ! [[ $packages_security_count =~ $re ]] ; then
        echo "# Warning: Could not get a number of system security packages waiting for update"
        packages_security_count="Nan"
    fi
    simple_metric system_updates_waiting gauge "number of system packages where a update is available" $packages_update_count
    simple_metric system_security_updates_waiting gauge "number of system packages where a security update is available" $packages_security_count
    
    echo "appliance:do_system_update=$($system_need_update && echo true || echo false)"
    if $system_need_update; then 
        echo "# information system update; forced: $system_forced , packages needing updates: $packages_update_count total , $packages_security_count security"
        echo "$restart_str"
    fi
    
}


check_docker_update(){
    local docker_list docker_old docker_new  
    local docker_forced=false
    local docker_need_update=false
    
    if test -e /app/etc/flags/force.update.docker; then 
        docker_need_update=true
        docker_forced=true
    fi

    # XXX needs up to date package list for proper results
    docker_list=$(apt-cache policy docker-engine -q | grep -E "(Installed|Candidate)")
    docker_old=$(printf "%s" "$docker_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    docker_new=$(printf "%s" "$docker_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$docker_old" != "$docker_new"; then
        docker_need_update=true
    fi

    echo "appliance:do_docker_update=$($docker_need_update && echo true || echo false)"
    if $docker_need_update; then 
        echo "# information docker update; forced: $docker_forced , current:$docker_old , new:$docker_new"
        echo "$restart_str"
    fi
}


check_compose_update() {
    local compose_need_update=false
    local compose_forced=false
    local update_path
    
    if test -e /app/etc/flags/force.update.compose; then 
        compose_need_update=true
        compose_forced=true
    fi
    
    update_path=$(/usr/local/bin/pip2 list -o | grep docker-compose)
    if test $? -eq 0; then
        compose_need_update=true
    fi

    echo "appliance:do_compose_update=$($compose_need_update && echo true || echo false)"
    if $compose_need_update; then 
        echo "# information compose update: forced: $compose_forced, path: $update_path"
        echo "$restart_str"
    fi
}


check_postgres_update(){
    local postgres_list postgres_old postgres_new
    local postgres_need_update=false
    local postgres_forced=false

    if test -e /app/etc/flags/force.update.postgres; then 
        postgres_need_update=true
        postgres_forced=true
    fi
    
    # XXX needs up to date package list for proper results
    postgres_list=$(apt-cache policy postgresql-9.5 -q | grep -E "(Installed|Candidate)")
    postgres_old=$(printf "%s" "$postgres_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    postgres_new=$(printf "%s" "$postgres_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$postgres_old" != "$postgres_new"; then
        postgres_need_update=true
    fi
  
    echo "appliance:do_postgres_update=$($postgres_need_update && echo true || echo false)"
    if $postgres_need_update; then
        echo "# information postgres update: forced: $postgres_forced , current: $postgres_old , new: $postgres_new"
        echo "$restart_str"
    fi
}


do_appliance_update() {
    local current_source proposed_source current_branch proposed_branch
    local targetid lastid
    local do_update=false
    
    if test ! -e /app/appliance; then install -g app -o app -d /app/appliance; fi
    cd /app/appliance
    current_source=$(current_source)
    proposed_source=$(proposed_source)
    current_branch=$(current_branch)
    proposed_branch=$(proposed_branch)

    # rewrite minion_id if different to env
    if test "$APPLIANCE_DOMAIN" != "$(cat /etc/salt/minion_id)"; then
        echo "setting minion_id to $APPLIANCE_DOMAIN"
        printf "%s" "$APPLIANCE_DOMAIN" > /etc/salt/minion_id
    fi

    if test "$proposed_source" = "saltmaster"; then
        echo "Warning: using saltmaster as appliance update source"
        do_update=true
    else
        if test "$proposed_source" != "$current_source"; then
            sentry_entry "Appliance Update" "Warning: appliance has different upstream sources, will re-clone. Current: \"$current_source\", new: \"$proposed_source\"" warning
            cd /; rm -r /app/appliance; install -g app -o app -d /app/appliance; cd /app/appliance
            gosu app git clone --branch $proposed_branch $proposed_source /app/appliance
            gosu app git submodule update --init --recursive
            do_update=true
        fi
    
        # fetch all updates from origin
        gosu app git fetch -a -p
        if test "$APPLIANCE_GIT_COMMITID" != ""; then
            targetid="$APPLIANCE_GIT_COMMITID"
        else
            targetid=$(gosu app git rev-parse origin/$proposed_branch)
        fi
        lastid=$(gosu app git rev-parse HEAD)
        
        if test "$lastid" != "$targetid" -o -e /app/etc/flags/force.update.appliance; then
            do_update=true
        fi
    fi
    
    if $do_update; then
        simple_metric appliance_last_update counter "timestamp-epoch-seconds since last update to appliance" $start_epoch_seconds
        appliance_status "Appliance Update" "Updating appliance from $lastid to $targetid"
        if test -e /app/etc/flags/force.update.appliance; then
            rm /app/etc/flags/force.update.appliance
        fi
        # hard update source
        gosu app git checkout -f $proposed_branch
        gosu app git reset --hard origin/$proposed_branch
        # call saltstack state.highstate to update appliance
        salt-call state.highstate pillar='{"appliance": {"enabled": true}}' --retcode-passthrough --return raven
        err=$?
        if test $err -ne 0; then
            appliance_exit "Appliance Error" "salt-call state.highstate failed with error $err"
        fi
        # save executed commit
        printf "%s" "$targetid" > /app/etc/tags/last_running_appliance
    fi

    simple_metric appliance_version gauge "appliance_version" 1 \
    "git_rev=\"$(gosu app git -C /app/appliance rev-parse HEAD)\",\
    git_branch=\"$(gosu app git -C /app/appliance rev-parse --abbrev-ref HEAD)\""
}


do_system_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
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
}


do_docker_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric docker_last_update counter "timestamp-epoch-seconds since last update to docker" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.docker; then
        rm /app/etc/flags/force.update.docker
    fi
    echo "# Information: docker update will be done in system update, this is a nop"
}


do_compose_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric compose_last_update counter "timestamp-epoch-seconds since last update to docker-compose" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.compose; then
        rm /app/etc/flags/force.update.compose
    fi
    pip2 install -U --upgrade-strategy only-if-needed docker-compose
}


do_postgres_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric postgres_last_update counter "timestamp-epoch-seconds since last update to postgres" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.postgres; then
        rm /app/etc/flags/force.update.postgres
    fi
    echo "Warning: prepare postgres update, kill all postgres connections to ecs except ourself"
    gosu app psql ecs -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'ecs' AND pid <> pg_backend_pid();"
}

