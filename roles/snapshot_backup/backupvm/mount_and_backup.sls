snapshot_backup_mount_and_backup:
  cmd.run:
    - name: false
{#
  salt "backup.minion_id" state.sls onlyonce=true roles.snapshot_backup.backupvm.mount_and_backup target_minion.id
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

cpu and io nicing:
${GHE_NICE:="nice -n 19"}
${GHE_IONICE:="ionice -c 3"}
#}
