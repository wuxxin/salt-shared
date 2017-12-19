#!/bin/bash

backup_hook() {
    if test "$1" = "--quiet"; then
        shift
        run_hook --quiet appliance-backup $@
    else
        run_hook appliance-backup $@
    fi
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

create_backup_config() {
    # create ready to use $gpgdir for backup being done using duplicity
    local gpgdir=/var/spool/duplicity/.gnupg
    local confdir=/var/spool/duplicity/.duply/appliance-backup
    local cachedir=/var/cache/duplicity/duply_appliance-backup
    
    install -g duplicity -o duplicity -m 700 -d $gpgdir
    find $gpgdir -mindepth 1 -name "*.gpg*" -delete
    echo "$APPLIANCE_BACKUP_ENCRYPT" | gosu duplicity gpg --homedir $gpgdir --batch --yes --import --
    
    # write out backup target and gpg_key to duply config
    gpg_key_id=$(gosu duplicity gpg --keyid-format 0xshort --list-key appliance-backup | grep pub | sed -r "s/pub.+0x([0-9A-F]+).+/\1/g")
    cat $confdir/conf.template | \
        sed -r "s#^TARGET=.*#TARGET=$APPLIANCE_BACKUP_URL#;s#^GPG_KEY=.*#GPG_KEY=$gpg_key_id#;s#^CUSTOM_DUPL_PARAMS=.*#CUSTOM_DUPL_PARAMS=\"$APPLIANCE_BACKUP_OPTIONS\"#;" > \
        $confdir/conf
    chown duplicity:duplicity $confdir/conf
    
    # check if we need to remove duplicity cache files, because backup url changed
    if test -e $confdir/conf.last; then
        cururl=$(cat $confdir/conf       | grep "^TARGET=" | sed -r 's/^TARGET=[ '\''"]*([^ '\''"]+).*/\1/')
        lasturl=$(cat $confdir/conf.last | grep "^TARGET=" | sed -r 's/^TARGET=[ '\''"]*([^ '\''"]+).*/\1/')
        if test "$cururl" != "$lasturl"; then
            sentry_entry "Appliance Backup" "warning: different backup url, deleting backup cache directory"
            rm -r $cachedir
            install -g duplicity -o duplicity -d $cachedir
        fi
    fi
    # add last backup config to cachedir, so we can detect if backup url has changed
    cp -a $confdir/conf $confdir/conf.last

    # generate backup file list
    backup_hook --quiet create_backup_filelist | sort | uniq; cat $confdir/exclude.template - > $confdir/exclude
    chown duplicity:duplicity $confdir/exclude
    
    # write warning to sentry if changed from last version
    if test -e $confdir/exclude.last; then
        if ! diff -q $confdir/exclude.last $confdir/exclude; then
            extra=$(diff -u $confdir/exclude.last $confdir/exclude| text2json)
            sentry_entry "Appliance Backup" "warning: different exclude list" "warning" $extra
        fi
    fi
    cp -a $confdir/exclude $confdir/exclude.last
}