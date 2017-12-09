#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/backup.functions.sh

usage(){
    cat << EOF
Usage:  $0 --yes-i-am-sure

recovers files from backup.

Requirements:
+ storage setup for target environment has already run
+ a valid environment with working backup config targeting the needed backup data

EOF
    exit 1
}

onlyrestore=false
if test "$1" = "--only-restore"; then
    onlyrestore=true
    shift
fi
if test "$1" != "--yes-i-am-sure"; then
    usage
fi

# check if valid active environment and activate environment
env-update.sh
ENV_YML=/run/active-env.yml userdata_to_env appliance
if test $? -ne 0; then echo "error: could not activate userdata environment"; usage; fi


# check if postgresql database ecs does not exist
gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw ecs
if test $? -eq 0; then echo "error: database ecs exists."; usage; fi

echo "stop appliance, disable backup run"
systemctl stop appliance
rm /app/etc/tags/last_running_appliance
systemctl disable appliance-backup

echo "write backup access config"
/etc/app/hooks/appliance-prepare/start/backup.sh

# test if appliance:backup:mount:type is set, mount backup storage
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
    echo "mount backup target"
    mount_backup_target
fi

echo "restore files and database dump from backup"
gosu duplicity duply /var/spool/duplicity/.duply/appliance-backup restore /data/restore
# add last backup config to cachedir, so we can detect if backup url has changed
cp /var/spool/duplicity/.duply/appliance-backup/conf  /var/spool/duplicity/.duply/appliance-backup/conf.last

# test if appliance:backup:mount:type is set, unmount backup storage
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
    echo "unmount backup target"
    unmount_backup_target
fi

echo "move restored files to target directory"
if test -e "/data/ecs-storage-vault-old"; then rm -r "/data/ecs-storage-vault-old"; fi
if test -e "/data/ecs-pgdump-old"; then rm -r "/data/ecs-pgdump-old"; fi
mv /data/ecs-storage-vault /data/ecs-storage-vault-old
mv /data/ecs-pgdump /data/ecs-pgdump-old
mv /data/restore/ecs-storage-vault /data/ecs-storage-vault
mv /data/restore/ecs-pgdump /data/ecs-pgdump

if $onlyrestore; then
    exit 0
fi

echo "import database from dump"
gosu postgres createuser app
gosu postgres createdb ecs -T template0 -l de_DE.utf8
gosu postgres psql -c "ALTER DATABASE ecs OWNER TO app;"
gosu app /bin/bash -c "cat /data/ecs-pgdump/ecs.pg_dump.gz | gzip -d | pg_restore -1 --format=custom --schema=public --no-owner --dbname=ecs"

echo "configure and restart appliance"
rm /run/appliance-failed
systemctl start appliance-update

echo "reenable backup"
systemctl enable appliance-backup
