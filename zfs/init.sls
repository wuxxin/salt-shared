include:
  - .ppa

zfs-on-linux:
  pkg.installed:
    - pkgs:
      - ubuntu-zfs
    - require:
      - pkgrepo: zfs_ppa

