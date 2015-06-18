include:
  - .ppa

zfs-on-linux:
  pkg.installed:
    - pkgs:
      - ubuntu-zfs
    - require:
      - cmd: zfs_ppa

