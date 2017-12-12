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
        
        need_appliance_update=$(check_appliance_update | grep -q "^appliance:do_appliance_update=true" && echo "true" || echo "false")
        
        mute_alerts # ignore job up alerts while update in progress

        if $need_appliance_update; then
            simple_metric appliance_last_update counter "timestamp-epoch-seconds since last update to appliance" $start_epoch_seconds
            do_appliance_update
            # call new version of self with the original start time
            exec $0 --continue $start_epoch_seconds "$@"
        fi
    fi

    # check for available updates
    apt-get update -y
    
    update_list=$(run_hook appliance-update check) 
    echo "Information: Updates List: $update_list"
    
    need_service_restart=$(echo "$update_list" | grep -q "#%need_service_restart=true" && echo "true" || echo "false")
    
    if $need_service_restart; then
        appliance_status "Appliance Update" "Preparing for Update"
        echo "Info: shutting down appliance, because update requested this"
        systemctl stop appliance
        sleep 2 # Wait a little to settle still open connections
    fi
        
    for update_name in $(echo "$update_list" | grep -v "^#" | sed -r "s/([^:]+):([^=])=(.+)/\1/g"); do
        update_entry=$(echo "$update_list" | grep "^$update_name:")
        update_func=$(echo "$update_entry" | sed -r "s/([^:]+):([^=])=(.+)/\2/g")
        update_param=$(echo "$update_entry" | sed -r "s/([^:]+):([^=])=(.+)/\3/g")
        run_hook appliance-update update $update_name $update_entry $update_param
    done
    
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
        appliance_status --active
    fi

    simple_metric update_running_time gauge "number of seconds for a update run" $(($(date +%s) - start_epoch_seconds))
    unmute_alerts
    exit 0
}
