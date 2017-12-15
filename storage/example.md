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

example: use whole disk for root partition

```
{% load_yaml as custom_storage %}
parted:
  /dev/vda:
    type: mbr {# can be mpr or gpt #}
    parts:
      - name root
        start: 1024kiB
        end: "100%"
        flags:
          - boot
          # flag list will be translated into parted flags
{% endload %}
```

## mdadm

example: make two raid1 devices md0=vdb2,vdc2, md1=vdb4,vdc4

```
{% load_yaml as custom_storage %}
mdadm:
  {% for a,b in [(0, 2), (1, 4)] %}
  "/dev/md{{ a }}":
    level: 1
    devices:
      - /dev/vdb{{ b }}
      - /dev/vdc{{ b }}
    # optional kwargs passed to mdadm.present
  {% endfor %}
{% endload %}
```


## format

example: format vda1 as ext4 with label root

```
{% load_yaml as custom_storage %}
format:
  /dev/mapper/vg0-host_root:
    fstype: ext4
    options: # passed to mkfs
      - "-L root"
    # optional kwargs passed to cmd.run
{% endload %}
```


## mount

example: mount /dev/mapper/vg0-images as /mnt/images if filesystem is ext4

```
{% load_yaml as custom_storage %}
mount:
  /mnt/images:
    device: /dev/mapper/vg0-images
    # optional kwargs for mount.mounted
    # defaults:
    #  fstype: ext4
    #  mkmnt: true 
{% endload %}
```


## directory

example: create directories under /volatile if /volatile is mountpoint.

```
{% load_yaml as custom_storage %}
directory:
  /volatile:
    mountpoint: true  # defaults to false
    parts:
      - name: docker
      - name: backup-test
      - name: alertmanager
        # optional kwargs for file.directory
        # defaults are makedirs:true
        user: 1000
        group: 1000
        dir_mode: 755
        file_mode: 644
{% endload %}
```

## full 

example (parted, madm, crypt, lvm:pv, lvm:vg, lvm:lv, format, mount, swap)

```
{% load_yaml as custom_storage %}
parted:
{% for a in ["/dev/vdb", "/dev/vdc"] %}
  {{ a }}:
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
  "/dev/md{{ a }}":
    level: 1
    devices:
      - /dev/vdb{{ b }}
      - /dev/vdc{{ b }}
    # optional kwargs passed to mdadm.present
{% endfor %}

crypt:
  "/dev/md1":
    password: "my-useless-password"
    target: "cryptlvm"

lvm:
  pv:
    devices:
      - /dev/mapper/cryptlvm
    # optional kwargs passed to lvm.pv_present
  vg:
    vg0:
      devices:
        - /dev/mapper/cryptlvm
      # optional kwargs passed to lvm.vg_present
  lv:
    host_root:
      vgname: vg0
      size: 2g
      # optional kwargs passed to lvm.lv_present
    other_volume:
      vgname: vg0
      size: 30g
      expand: true 
      # no optional kwargs are passed, volume must exist, volume is resized
      
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

swap:
  - /dev/mapper/vg0-host_swap

directory:
  /mnt/images:
    mountpoint: true  # defaults to false
    parts:
      - name: docker
      - name: funnydir
        # optional kwargs for file.directory
        # defaults are makedirs:true
        user: 1000
        group: 1000
        dir_mode: 755
        file_mode: 644

relocate:
  - source: /var/lib/docker
    target: /mnnt/images/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
  - source: /app/.cache/duplicity
    target: /mnt/images/duplicity

```

