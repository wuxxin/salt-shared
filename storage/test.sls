{% from 'storage/lib.sls' import storage_setup %}

test:
  test:
    - nop
another:
  test:
    - nop
in_test:
  test:
    - nop
in_another:
  test:
    - nop


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
    require:
      - test: test
      - test: another
    require_in:
      - test: in_test
      - test: in_another
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
      require:
        - test: test
      require_in:
        - test: in_another

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
        require:
          - test: test
        require_in:
          - test: in_test
          - test: in_another

relocate:
  - source: /var/lib/docker
    target: /mnnt/images/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
  - source: /app/.cache/duplicity
    target: /mnt/images/duplicity

{% endload %}

{{ storage_setup(custom_storage) }}
