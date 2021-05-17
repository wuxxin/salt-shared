{% from "zfs/defaults.jinja" import settings with context %}

include:
  - kernel.nfs.server
  - zfs.autosnapshot

zfsutils-linux:
  pkg.installed:
    - require:
      - sls: kernel.nfs.server

zfs-support-libvirt:
  pkg.installed:
    - name: libvirt-daemon-driver-storage-zfs
    - require:
      - pkg: zfsutils-linux

/etc/modprobe.d/zfs.conf:
  file.managed:
    - contents: |
        options zfs zfs_arc_max={{ settings.arc_max_bytes }}
