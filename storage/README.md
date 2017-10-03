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
 
 * directories: skeleton directory creation
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

### Full example

```
storage:
  parted:
{% for a in ["/dev/vdb", "/dev/vdc"] %}
    {{ a }}:
      {# if you leave out type, no partition table will be recreated #}
      type: gpt {# or "mbr" for [ms]dos type boot record #}
      parts:
        - name: bios_grub
          start: 1024kiB
          end: 2048Kib
          flags:
            - bios_grub
        - name: boot
          start: 2048KiB
          end: 256Mib
          flags:
            - raid
        - name: reserved
          start: 256Mib
          end: "{{ 256+ 2048 }}Mib"
        - name: data
          start: "{{ 256+ 2048 }}Mib"
          end: "100%"
          flags:
            - raid
{% endfor %}

  mdadm:
{% for a,b in [(0, 2), (1, 4)] %}
    "/dev/md{{ a }}":
      - level=1
      - devices:
        - /dev/vdb{{ b }}
        - /dev/vdc{{ b }}
      {#
      - optional kwargs passed to mdadm.
      #}

{% endfor %}

  crypt:
    "/dev/md1":
      password: "my-useless-password"
      target: "cryptlvm"

  lvm:
    pv:
      - /dev/mapper/cryptlvm
    vg:
      vg0:
        - devices:
          - /dev/mapper/cryptlvm
        {#
        - optional kwargs passed to lvm.
        #}
    lv:
      host_root:
        vgname: vg0
        size: 2g
      host_swap:
        vgname: vg0
        size: 2g
      images:
        vgname: vg0
        size: 1g
      cache:
        vgname: vg0
        size: 1g

  format:
    /dev/md0:
      fstype: ext3
    /dev/mapper/vg0-host_root:
      fstype: ext4
      options: {# passed to mkfs #}
        - "-L my_root"
    /dev/mapper/vg0-host_swap:
      fstype: swap
    /dev/mapper/vg0-images:
      fstype: ext4
      options:
        - "-L images"
    /dev/mapper/vg0-cache:
      fstype: ext4

  mount:
    /mnt/images:
      device: /dev/mapper/vg0-images
      fstype: ext4
      mkmnt: true {# additional args for mount.mounted #}
    /mnt/cache:
      device: /dev/mapper/vg0-cache
      fstype: ext4
      mkmnt: true

  swap:
    - /dev/mapper/vg0-host_swap

```

## Additional Parameter

### optional kwargs in mdadm, lvm:vg, lvm:lv, mount

    mdadm:  passed to mdadm.raid_present
    lvm vg: passed to lvm.vg_present
    lvm lv: passed to lvm.lv_present
    mount:  passed to mount.mounted

Example:
```
lvm:
  lv:
    test:
      vgname: vg0
      size: 10g
      wipesignatures: yes
```

### "options" in format:

    "options" parameter: list of options passed to mkfs

Example:
```
format:
  /dev/mapper/vg0-host_root:
    fstype: ext4
    options:
      - "-L my_root"
```

### "watch_in/require_in/require/watch" in lvm:lv, format:

    if set will insert a "watch/require/_in" into the state

Example:
```
format:
  /dev/mapper/vg0-host_cache:
    watch_in: "service: cacher-setup"
```

### parameter "expand" in lvm:lv:

    if set to true and volume exists,
    it will try to expand the existing lv to the desired size,
    ignoring any other parameters beside size and vgname.
    if lv does not exist it will create it with all parameters attached.
    if the lv exists and has a filesystem of ext2,ext3,ext4 already on it,
    the filesystem will be resized.

Example:
```
lvm:
  lv:
    cache:
      vgname: vg0
      size: 12g
      expand: true
```
