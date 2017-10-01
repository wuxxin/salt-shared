prepare_backup () {
    # create ready to use /root/.gnupg for backup being done using duplicity
    mkdir -p /root/.gnupg
    find /root/.gnupg -mindepth 1 -name "*.gpg*" -delete
    echo "$APPLIANCE_BACKUP_ENCRYPT" | gpg --homedir /root/.gnupg --batch --yes --import --
    # write out backup target and gpg_key to duply config
    gpg_key_id=$(gpg --keyid-format 0xshort --list-key ecs_backup | grep pub | sed -r "s/pub.+0x([0-9A-F]+).+/\1/g")
    cat /root/.duply/appliance-backup/conf.template | \
        sed -r "s#^TARGET=.*#TARGET=$APPLIANCE_BACKUP_URL#;s#^GPG_KEY=.*#GPG_KEY=$gpg_key_id#;s#^CUSTOM_DUPL_PARAMS=.*#CUSTOM_DUPL_PARAMS=\"$APPLIANCE_BACKUP_OPTIONS\"#;" > \
        /root/.duply/appliance-backup/conf
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
