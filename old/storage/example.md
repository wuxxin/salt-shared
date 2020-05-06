# Storage Examples

* [parted](parted):  (gpt/mbr) partition creation
* [mdadm](mdadm):    raid creation
* [crypt](crypt):    luks partition creation
* [lvm: pv](lvm:pv): create a lvm pysical volume
* [lvm: vg](lvm:vg): create a lvm volume group
* [lvm: lv](lvm:lv): create or expand (+ fs expand) a lvm logical volume
* [format](format):  format partitions
* [mount](mount):    mount partitions (persistent)
* [swap](swap):      mount swap (persistent)
* [directory](directory): skeleton directory creation
* [relocate](relocate):   relocate data and make a symlink from old to new location 
* [full example](full): all storage functions in one example


## parted

#### example: use whole disk for root partition
```
parted:
  - device: /dev/vda
    type: mbr # can be mpr or gpt
    parts:
      - name root
        start: 1024kiB
        end: "100%"
        flags:
          - boot
          # flag list will be translated into parted flags
```

## mdadm

#### example: make two raid1 devices md0=vdb2,vdc2, md1=vdb4,vdc4
```
mdadm:
  {% for a,b in [(0, 2), (1, 4)] %}
  - target: /dev/md{{ a }}"
    level: 1
    devices:
      - /dev/vdb{{ b }}
      - /dev/vdc{{ b }}
    # optional kwargs passed to mdadm.raid_present
  {% endfor %}
```

## crypt
#### example: crypt device /dev/md1 and make it available under /dev/cryptlvm
```
crypt:
  - device: /dev/md1
    name: "cryptlvm"
    password: "my-useless-password"
    # optional kwargs for cmd.run:cryptsetup luksFormat, cmr.run:cryptsetup open
```

## lvm:pv
#### example: format a device as physical lvm volume
```
lvm:
  pv:
    devices: 
      - /dev/vdb1
    # optional kwargs for lvm.pv_present
```

## lvm:vg
#### example: use device vdb1 (which is formated as lvm:pg volume) as volume group
```
lvm:
  vg:
    - name: vg0
      devices:
        - /dev/vdb1
      # optional kwargs passed to lvm.vg_present
```

## lvm:lv
#### example: create logical volume host_root on volume group vg0 with 100g size
```
lvm:
  lv:
    - name: host_root
      vgname: vg0
      size: 100g
      # optional kwargs passed to lvm.lv_present
```
#### example: expand already existing logical volume other_volume to 50g target size
```
lvm:
  lv:
    - name: other_volume
      size: 50g
      expand: true
      # no optional kwargs are passed, volume must exist, volume is resized
```

## format
#### example: format logical volume host_root with type ext4 and label name my_root
```
format:
  - device: /dev/mapper/vg0-host_root
    fstype: ext4
    options: # passed to mkfs
      - "-L my_root"
    # optional kwargs passed to cmd.run
```

## mount
#### example: mount logical volume images of volume group vg0 to /mnt/images
```
mount:
  - device: /dev/mapper/vg0-images
    target: /mnt/images
    # optional kwargs for mount.mounted
    # defaults:
    #  fstype: ext4
    #  mkmnt: true 
```

## swap
#### example: add logical volume host_swap in volume group vg0 as swap
```
swap:
  - /dev/mapper/vg0-host_swap
```

## directory
#### example: make a directory structure under mountpoint /volatile
```
directory:
  - name: /volatile
    mountpoint: true  # defaults to false
    # optional kwargs for file.directory
    # defaults are makedirs:true
  - name: /volatile/docker
  - name: /volatile/alertmanager
    # optional kwargs for file.directory
    # defaults are makedirs:true
    user: 1000
    group: 1000
    dir_mode: 755
    file_mode: 644
```

## relocate

### example: relocate docker and other directory
```
relocate:
  - source: /var/lib/docker
    target: /volatile/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
    # optional kwargs for cmd.run:prefix, file.rename, file.symlink, cmd.run:postfix
  - source: /app/.cache/duplicity
    target: /volatile/duplicity
```


## full 

example (parted, madm, crypt, lvm:pv, lvm:vg, lvm:lv, format, mount, swap)

```
{% load_yaml as custom_storage %}
parted:
{% for a in ["/dev/vdb", "/dev/vdc"] %}
  - device: {{ a }}
    type: gpt 
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
  - target: /dev/md{{ a }}
    level: 1
    devices:
      - /dev/vdb{{ b }}
      - /dev/vdc{{ b }}
    # optional kwargs passed to mdadm.present
{% endfor %}

crypt:
  - device: /dev/md1
    password: "my-useless-password"
    target: cryptlvm

lvm:
  pv:
    devices:
      - /dev/mapper/cryptlvm
    # optional kwargs passed to lvm.pv_present
  vg:
    - name: vg0
      devices:
        - /dev/mapper/cryptlvm
      # optional kwargs passed to lvm.vg_present
  lv:
    - name: host_root
      vgname: vg0
      size: 2g
      # optional kwargs passed to lvm.lv_present
    - name: other_volume
      vgname: vg0
      size: 30g
      expand: true 
      # no optional kwargs are passed, volume must exist, volume is resized
      
format:
  - device: /dev/md0
    fstype: ext3
  - device: /dev/mapper/vg0-host_root
    fstype: ext4
    options: {# passed to mkfs #}
      - "-L my_root"
  - device: /dev/mapper/vg0-host_swap
    fstype: swap
  - device: /dev/mapper/vg0-images
    fstype: ext4
    options:
      - "-L images"
  - device: /dev/mapper/vg0-cache
    fstype: ext4

mount:
  - device: /dev/mapper/vg0-images
    target: /mnt/images
    fstype: ext4
    mkmnt: true {# additional args for mount.mounted #}
  - device: /dev/mapper/vg0-cache
    target: /mnt/cache

swap:
  - /dev/mapper/vg0-host_swap

directory:
  - name: /mnt/images
    mountpoint: true  # defaults to false
    # optional kwargs for file.directory
    # defaults are makedirs:true
  - name: /mnt/images/docker
  - name: /mnt/images/funnydir
    # optional kwargs for file.directory
    # defaults are makedirs:true
    user: 1000
    group: 1000
    dir_mode: 755
    file_mode: 644

relocate:
  - source: /var/lib/docker
    target: /mnt/images/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
    # optional kwargs for cmd.run:prefix, file.rename, file.symlink, cmd.run:postfix
  - source: /app/.cache/duplicity
    target: /mnt/images/duplicity

```

