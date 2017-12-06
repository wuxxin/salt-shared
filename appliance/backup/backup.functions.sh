#!/bin/bash

backup_hook() {
    run_hook appliance-backup $@
}
  
mount_backup_target() {
    local opts
    if test ! -e "$APPLIANCE_BACKUP_MOUNT_TARGET"; then
        echo "Information creating backup mount directory $APPLIANCE_BACKUP_MOUNT_TARGET"
        if ! mkdir -p $APPLIANCE_BACKUP_MOUNT_TARGET; then
            sentry_entry "Appliance Backup" "backup abort: could not create mountpoint"
            exit 1
        fi
    fi

    echo "Mounting $APPLIANCE_BACKUP_MOUNT_SOURCE type $APPLIANCE_BACKUP_MOUNT_TYPE to $APPLIANCE_BACKUP_MOUNT_TARGET"
    if test "$APPLIANCE_BACKUP_MOUNT_OPTIONS" != ""; then
        mount -t $APPLIANCE_BACKUP_MOUNT_TYPE \
        "$APPLIANCE_BACKUP_MOUNT_SOURCE" "$APPLIANCE_BACKUP_MOUNT_TARGET" \
        -o "$APPLIANCE_BACKUP_MOUNT_OPTIONS"
    else
        mount -t $APPLIANCE_BACKUP_MOUNT_TYPE \
        "$APPLIANCE_BACKUP_MOUNT_SOURCE" "$APPLIANCE_BACKUP_MOUNT_TARGET"
    fi
    if ! mountpoint "$APPLIANCE_BACKUP_MOUNT_TARGET"; then
        sentry_entry "Appliance Backup" "backup abort: could not mount backup storage to $APPLIANCE_BACKUP_MOUNT_TARGET"
        exit 1
    fi
}

unmount_backup_target() {
    if ! mountpoint "$APPLIANCE_BACKUP_MOUNT_TARGET"; then
        echo "Warning: Mountpoint $APPLIANCE_BACKUP_MOUNT_TARGET is already unmounted"
    else
        echo "Unmounting $APPLIANCE_BACKUP_MOUNT_TARGET"
        umount --lazy $APPLIANCE_BACKUP_MOUNT_TARGET
    fi
}
