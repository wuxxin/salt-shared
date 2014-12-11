setup harddisk storage
======================

Features:
 * (gpt/mbr) partition creation
 * mdadm raid creation
 * luks partition creation
 * lvm logical volumes creation and expansion (with expansion of fs if in ext2,ext3,ext4)
 * format partitions
 * mount partitions
 * mount swap
 * skeleton directory creation
 * relocate data and make a symlink from old location to new location


callable via:
--------------
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(data) }}

Usage:
------

For example data see: example.pillar

**Warning**: lvm makes a difference if you use "g" or "G" for gigabyte.
g=GiB (1024*1024*1024) and G means 1000*1000*1000

Additions to the default options the salt states:

"format", "directories", "relocate": optional arguments (watch_in, require_in, require, watch):
...............................................................................................
if set will insert a "watch/require/_in" into the format,directories,relocate state

Example:

---
  relocate:
    /var/cache/apt-cacher-ng:
      destination: /mnt/cache/apt-cacher-ng
      copy_content: false
      watch_in: "service: apt-cacher-ng"


"directories": optional arguments (onlyif, unless):
...................................................
will insert a onlyif/unless state requirement

Example:

---
  directories:
    /mnt/images:
      options:
        - user: libvirt-qemu
        - group: libvirtd
        - dir_mode: 2775
      names:
        - default
        - iso
        - templates
        - tmp
      onlyif: mountpoint -q /mnt/images


"lvm:lv": additional argument: "expand":
........................................

if set to true and volume exists, 
it will try to expand the existing lv to the desired size, 
ignoring any other parameters beside size and vgname.
if lv does not exist it will create it with all parameters attached.
if the lv exists and has a filesystem of ext2,ext3 or ext4 already on it,
the filesystem will be resized.

Example:

---
  lvm:
    lv:
      cache:
        vgname: omoikane
        size: 12g
        expand: true

