# setup storage

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
 * directory:   skeleton directory creation
 * relocate:    relocate data and make a symlink from old to new location

**Warning**: lvm makes a difference if you use "g" or "G" for gigabyte.
  * g=GiB (1024*1024*1024) , G= (1000*1000*1000)

## Usage

```
{% load_yaml as data %}
lvm:
  lv:
    my_lvm_volume:
      vgname: vg0
      size: 2g
{% endload %}
{% from 'storage/lib.sls' import storage_setup %}
{{ storage_setup(data) }}
```

See (example.md)[example.md] for detailed parameter usage.


## Additional Parameter

### optional kwargs in every state (except parted, crypt, swap)

+ mdadm:  passed to mdadm.raid_present
+ lvm pv: passed to lvm.pv_present
+ lvm vg: passed to lvm.vg_present
+ lvm lv: passed to lvm.lv_present
+ format: passed to cmd.run
+ mount:  passed to mount.mounted
+ directory: passed to file.directory
+ relocate: passed to prefix:cmd, relocate:file, symlink:file, postfix:cmd

in addition to optional kwargs for target state, 
you can add standard saltstack parameter like "watch_in/require_in/require/watch" 


+ state specific option example

```
lvm:
  lv:
    test:
      vgname: vg0
      size: 10g
      wipesignatures: yes
```

+ generic salstack option example

```
format:
  /dev/mapper/vg0-host_cache:
    watch_in: 
      - pkg: cache-setup
```

### parameter "options" in format:

"options" parameter: list of options passed to mkfs

Example:

```
format:
  /dev/mapper/vg0-host_root:
    fstype: ext4
    options:
      - "-L my_root"
```

### parameter "expand" in lvm:lv:

if set to true and volume exists,
  it will expand the existing lv to the desired size,
  ignoring any other parameters beside size and vgname.
  if the lv has a filesystem of ext2,ext3,ext4 already on it,
  the filesystem will be resized.

if lv does not exist it will create it with all parameters attached.
    
Example:

```
lvm:
  lv:
    cache:
      vgname: vg0
      size: 12g
      expand: true
```
