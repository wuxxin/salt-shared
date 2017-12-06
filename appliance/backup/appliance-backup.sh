#!/bin/bash
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/backup.functions.sh
. /usr/local/share/appliance/metric.functions.sh

# remember start time
start_epoch_seconds=$(date +%s)
confdir=/app/.duply/appliance-backup

backup_hook prefix_mount
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
    mount_backup_target
fi
backup_hook postfix_mount

backup_hook prefix_cleanup
# duplicity to thirdparty
gosu app /usr/bin/duply $confdir cleanup --force
if test "$?" -ne "0"; then
    sentry_entry "Appliance Backup" "duply cleanup error" "warning" \
        "$(service_status appliance-backup.service)"
fi

backup_hook prefix_backup
gosu app /usr/bin/duply $confdir backup
if test "$?" -ne "0"; then
    sentry_entry "Appliance Backup" "duply backup error" "error" \
        "$(service_status appliance-backup.service)"
    exit 1
fi

backup_hook prefix_purge
gosu app /usr/bin/duply $confdir purgefull --force
if test "$?" -ne "0"; then
    sentry_entry "Appliance Backup" "duply purge-full error" "warning" \
        "$(service_status appliance-backup.service)"
fi

# calculate used space; xxx not all volumes have max size, but the more data the less the error margin
volumesizekb=$(( 25*1024))
volumes=$(/usr/bin/duply $confdir/ status | \
    grep "Total number of contained volumes:" | \
    sed -r "s/[^:]+[^0-9]*([0-9]+)/\1/g" | \
    awk '{s+=$1} END {print s}')
backupspacekb=$(( volumes * volumesizekb ))
# sum the filesizes of the backuped directories
backupdatasizekb=$(du --apparent-size --summarize --total -BK /data/ecs-storage-vault/ /data/ecs-pgdump/ | grep total | sed -r "s/([0-9]+).*/\1/")

backup_hook prefix_unmount
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
    unmount_backup_target
fi
backup_hook postfix_unmount

# calculate runtime
end_epoch_seconds=$(date +%s)
duration=$(( end_epoch_seconds - start_epoch_seconds ))

# create and export metric to prometheus
backup_last_start_time=$(mk_metric backup_last_start_time counter "The start of the last backup run as timestamp-epoch-seconds" ${start_epoch_seconds})
backup_last_duration=$(mk_metric backup_last_duration gauge "The number of seconds of the last backup run" $duration)
backup_last_size=$(mk_metric backup_last_size gauge "The number of kilo-bytes used in backupspace" $backupspacekb)
backup_last_volumes=$(mk_metric backup_last_volumes gauge "The number of 25mb volumes used in backupspace" $volumes)
backup_last_data_size=$(mk_metric backup_last_data_size gauge "The sum of the filesizes of the backuped directories in kilo-bytes" $backupdatasizekb)
metric_export backup "${backup_last_start_time}" "${backup_last_duration}" "${backup_last_size}" "${backup_last_volumes}" "${backup_last_data_size}"
