#!/bin/bash

. /usr/local/share/appliance/env.functions.sh

create_backup_config() {
    # create ready to use $gpgdir for backup being done using duplicity
    local gpgdir=/var/spool/duplicity/.gnupg
    local confdir=/var/spool/duplicity/.duply/appliance-backup
    local cachedir=/var/cache/duplicity/duply_appliance-backup
    
    install -g duplicity -o duplicity -d $gpgdir
    find $gpgdir -mindepth 1 -name "*.gpg*" -delete
    echo "$APPLIANCE_BACKUP_ENCRYPT" | gosu duplicity gpg --homedir $gpgdir --batch --yes --import --
    
    # write out backup target and gpg_key to duply config
    gpg_key_id=$(gosu duplicity gpg --keyid-format 0xshort --list-key appliance_backup | grep pub | sed -r "s/pub.+0x([0-9A-F]+).+/\1/g")
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
    run_hook backup_files_list | sort | uniq; cat - $confdir/exclude.template > $confdir/exclude
    chown duplicity:duplicity $confdir/exclude
    
    # write warning to sentry if changed from last version
    if test -e $confdir/exclude.last; then
        if ! diff -q $confdir/exclude.last $confdir/exclude; then
            extra=$(diff -u $confdir/exclude.last $confdir/exclude| text2json)
            sentry_entry "Appliance Backup" "warning: different exclude list" "warning" $extra
        fi
    fi
    # add current files list to cachedir, for change detection
    cp -a $confdir/exclude $cachedir/exclude
}

userdata_to_env appliance

backup_hook prefix_config
create_backup_config
backup_hook postfix_config

