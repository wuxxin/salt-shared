#!/bin/bash


check_system_update() {
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
        postgres_need_update=true
    fi
    $postgres_need_update
}


check_appliance_update(){
    local current_source target last_running
    local appliance_need_update=true
    
    if test ! -e /app/etc/flags/force.update.appliance; then 
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
    fi
    
    echo "need_appliance_update=$($appliance_need_update && echo true || echo false)"
}

