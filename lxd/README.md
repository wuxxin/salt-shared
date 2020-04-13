# lxd

## security remark: a user with group lxd is equivalent to passwordless sudo

+ adding a user to group lxd is equivalent (with more work) to a passwordless sudo, aka. root
+ use sudo or be root while using lxc cmdline utility
see: https://shenaniganslabs.io/2019/05/21/LXD-LPE.html

## Examples

### gui profile example

```
profiles:
- name: gui
  config:
    environment.DISPLAY: :0
    raw.idmap: both 1000 1000
    user.user-data: |
      #cloud-config
      runcmd:
        - 'sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/client.conf'
        - 'echo export PULSE_SERVER=unix:/tmp/.pulse-native | tee --append /home/ubuntu/.profile'
      packages:
        - x11-apps
        - mesa-utils
        - pulseaudio
  description: LXD Gui Profile
  devices:
    PASocket:
      path: /tmp/.pulse-native
      source: /run/user/1000/pulse/native
      type: disk
    X0:
      path: /tmp/.X11-unix/X0
      source: /tmp/.X11-unix/X0
      type: disk
    mygpu:
      type: gpu
```

### zfs config example

```
lxd:
  storage_pools:
  - name: zfs
    description: LXD zfs pool
    driver: zfs
    config:
      source: rpool/data/lxd
      zfs.pool_name: rpool/data/lxd

  profiles:
  - name: default
    devices:
      root:
        path: /
        pool: zfs
        type: disk
```

### cloud init compatible images metadata passing example
```
    config:
      user.network-config: |
        version: 1
        config:
          - type: physical
            name: eth1
            subnets:
              - type: static
                ipv4: true
                address: 10.10.101.20
                netmask: 255.255.255.0
                gateway: 10.10.101.1
                control: auto
          - type: nameserver
            address: 10.10.10.254
```
