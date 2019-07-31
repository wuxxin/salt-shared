# lxd

see defaults.jinja for config Options

## security issue: user to group lxd

+ adding a user to group lxd is equivalent (with more work) to a passwordless sudo
+ use sudo or be root while using lxc cmdline utility

see: https://shenaniganslabs.io/2019/05/21/LXD-LPE.html


## Examples

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
