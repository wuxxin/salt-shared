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
    - name: my_lvm_volume
      vgname: vg0
      size: 2g
{% endload %}
{% from 'storage/lib.sls' import storage_setup %}
{{ storage_setup(data) }}
```

See [example.md](example.md) for detailed parameter usage.


## Additional Parameter


optional kwargs in every state (except parted, swap) are passed to:

item | passed to state
--- | ---
mdadm | mdadm.raid_present
crypt | cmd.run:cryptsetup luksFormat, cmd.run:cryptsetup open
lvm:pv | lvm.pv_present
lvm:vg | lvm.vg_present
lvm:lv | lvm.lv_present
format | cmd.run:mkfs
mount | mount.mounted
directory | file.directory
relocate | cmd.run:prefix, file.rename, file.symlink, cmd.run:postfix


### state generic parameter

in addition to optional kwargs for target state, you can add standard saltstack state parameter like "watch_in/require_in/require/watch".

example:

```
lvm:
  lv:
    - name: host_cache
      size: 10g
      # generic salt state parameter
      watch_in: 
        - pkg: cache-setup
```

### state specific parameter

example:

```
lvm:
  lv:
    - name: test
      vgname: vg0
      size: 10g
      # optional parameter for lvm.lv_present
      wipesignatures: yes
```


### parameter "options" in format:

+ "options" parameter: list of options passed to mkfs

Example:

```
format:
  - device: /dev/mapper/vg0-host_root
    fstype: ext4
    options:
      - "-L my_root"
```

### parameter "expand" in lvm:lv:

+ "expand" parameter: true or false, default false

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
    - name: cache
      vgname: vg0
      size: 12g
      expand: true
```
