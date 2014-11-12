setup harddisk storage
======================

Features:
 * (gpt/mbr) partition creation
 * mdadm raid creation
 * luks partition creation
 * lvm logical volumes creation
 * format partitions
 * mount partitions
 * mount swap
 * skeleton directory creation
 * relocate data and make a symlink from old location to new location

Warning: lvm makes a difference if you use "g" or "G" for gigabyte.
g=GiB (1024*1024*1024) and G means 1000*1000*1000

todo:
  * restructure lvm.lv that you can write, and expand:True means if size of current existing lv is less than we will expand to size

lvm:
  lv:
    vg0:
      host_root:
        size: 2g
      host_swap:
        size: 2g
        expand: True (default false)


callable via:

{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(data) }}

sample data: example.pillar

pillar structure "directories" and "relocate" take optional arguments, that behave like in states:
  onlyif, unless: (only in directories)
  watch_in, require_in, require, watch

you can only list one watch_in, require_in, require, watch, onlyif, unless statement per pillar structure.

example:
  see /apt-cacher-ng
