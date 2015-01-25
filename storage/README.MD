= setup harddisk storage

Features:
 * parted:      (gpt/mbr) partition creation
 * mdadm:       raid creation
 * crypt:       luks partition creation
 * lvm: pv:     create a lvm pysical volume
 * lvm: vg:     create a lvm volume group
 * lvm: lv:     create or expand (+ fs expand) a lvm logical volume 
 * format:      format partitions
 * mount:       mount partitions (persistent)
 * swap:        mount swap (persistent)
 * directories: skeleton directory creation
 * relocate:    relocate data and make a symlink from old to new location

== Usage

```
{% load_yaml as data %}
lvm:
  lv:
    my_lvm_volume:
      vgname: vg0
      size: 2g
{% endload %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(data) }}
```

For a complete example see: example.pillar

**Warning**: lvm makes a difference if you use "g" or "G" for gigabyte.
g=GiB (1024*1024*1024) and G means 1000*1000*1000

== Additional options
=== for "lvm: lv", "format", "directories", "relocate"
==== option: watch_in/require_in/require/watch

if set will insert a "watch/require/_in" into the state

Example:
```
  relocate:
    /var/cache/apt-cacher-ng:
      destination: /mnt/cache/apt-cacher-ng
      copy_content: false
      watch_in: "service: apt-cacher-ng"
```
=== for "directories"
==== option: onlyif/unless

will insert a onlyif/unless state requirement

Example:
```
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
```

=== for "lvm:lv"
==== option: expand

if set to true and volume exists, 
it will try to expand the existing lv to the desired size, 
ignoring any other parameters beside size and vgname.
if lv does not exist it will create it with all parameters attached.
if the lv exists and has a filesystem of ext2,ext3 or ext4 already on it,
the filesystem will be resized.

Example:
```
  lvm:
    lv:
      cache:
        vgname: omoikane
        size: 12g
        expand: true
```


=== other additional options ===

some (!list them) states try to expose additional arguments to the primary underlying state.


Example:
```
  lvm:
    lv:
      test:
        vgname: omoikane
        size: 10g
        wipesignatures: y
```
