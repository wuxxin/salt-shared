# lxd

## security issue: user to group lxd

see: https://shenaniganslabs.io/2019/05/21/LXD-LPE.html

{% if salt['pillar.get']('desktop:development:enabled', false) %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}
{{ add_to_groups(user, 'lxd') }}
{% endif %}

## zfs pillar setup

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
