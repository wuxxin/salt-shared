snapshot-backup_mount_and_backup:
  cmd.run:
    - name: false
{#
  salt "backup.minion_id" state.sls onlyonce=true roles.snapshot-backup.backupvm.mount_and_backup target_minion.id
    mount access to a file share or a lvm filesystem volume 
        (backupvm_cache_volume with write access, 
        for storing duplicity cache files (--archive-dir --name ),
        duply config files)
    mdadm --assemble --scan # assemble raid 
    lvchange something # and lvm
    mount -ro something /target/something
    update duply config from salt to duply_config dir
    run duply
    unmount everthing we can
    emit snapshot done target_minion.id result

check free space on backup drive
apt-get install sftp
echo "df"     | sftp BENUTZERNAME@BACKUPSERVER
echo "df -h"  | sftp BENUTZERNAME@BACKUPSERVER
echo "df -hi" | sftp BENUTZERNAME@BACKUPSERVER

cpu and io nicing:
${GHE_NICE:="nice -n 19"}
${GHE_IONICE:="ionice -c 3"}
#}
