#!/bin/bash
. /usr/local/share/appliance/env.include
. /usr/local/share/appliance/prepare-backup.sh

usage(){
    cat << EOF
Usage:  $0 [--only-restore] --yes-i-am-sure

recovers database and files from backup.

Requirements:
+ storage setup for target environment has already run
+ a valid environment with working backup config targeting the needed backup data
+ /data/ecs-storage-vault directory, must exist and be empty
+ /data/ecs-pgdump directory, must exist and be empty
+ postgresql database ecs must not exist

Option: --only-restore: do not import database dump after restore, do not restart appliance

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

# check if existing and empty /data/ecs-storage-vault and /data/ecs-pgdump
for d in /data/ecs-storage-vault /data/ecs-pgdump; do
    if test ! -d $d; then
        echo "error: directory $d does not exist. run storage setup first";
        usage
    fi
    files_found=$(find $d -mindepth 1 -type f -exec echo true \; -quit)
    if test "$files_found" = "true"; then
        echo "error: directory $d is not empty. it must be empty"
        usage
    fi
done

# check if postgresql database ecs does not exist
gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw ecs
if test $? -eq 0; then echo "error: database ecs exists."; usage; fi

echo "stop appliance, disable backup run"
systemctl stop appliance
rm /app/etc/tags/last_running_ecs
systemctl disable appliance-backup

echo "write duply config"
prepare_backup

# test if appliance:backup:mount:type is set, mount backup storage
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
    mount_backup_target
fi

echo "restore files and database dump from backup"
duply /root/.duply/appliance-backup restore /data/restore
# add last backup config to cachedir, so we can detect if backup url has changed
cp /root/.duply/appliance-backup/conf  /root/.cache/duplicity/duply_appliance-backup/conf

# test if appliance:backup:mount:type is set, unmount backup storage
if test "$APPLIANCE_BACKUP_MOUNT_TYPE" != ""; then
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
