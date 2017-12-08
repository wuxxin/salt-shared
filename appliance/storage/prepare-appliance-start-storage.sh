#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh


prepare_storage () {
    need_storage_setup=false
    for d in /data/etc /data/ca /data/pgdump /data/postgresql \
        /volatile/docker /volatile/backup-test /volatile/prometheus \ /volatile/alertmanager /volatile/grafana /volatile/duplicity; do
        if test ! -d $d ; then
            echo "Warning: could not find directory $d"
            need_storage_setup=true
        fi
    done
    if test "$(findmnt -S "LABEL=volatile" -f -l -n -o "TARGET")" = ""; then
        if is_falsestr "$APPLIANCE_STORAGE_IGNORE_VOLATILE"; then
            echo "Warning: could not find mount for volatile filesystem"
            need_storage_setup=true
        fi
    fi
    if test "$(findmnt -S "LABEL=data" -f -l -n -o "TARGET")" = ""; then
        if is_falsestr "$APPLIANCE_STORAGE_IGNORE_DATA"; then
            echo "Warning: could not find mount for data filesystem"
            need_storage_setup=true
        fi
    fi
    if $need_storage_setup; then
        echo "calling appliance.storage setup"
        salt-call state.sls appliance.storage.setup --retcode-passthrough --return raven
        err=$?
        if test "$err" -ne 0; then
            appliance_failed "Appliance Error" "Storage Setup: Error, appliance.storage setup failed with error: $err"
        fi
    fi
}


userdata_to_env appliance
prepare_storage
