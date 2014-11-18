snapshot_backup_vm:
  pkg.installed:
    - pkgs:
      - duplicity
      - parted
      - lvm2
      - mdadm
      - cryptsetup




