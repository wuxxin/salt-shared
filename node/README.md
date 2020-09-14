# Node state

Configures hostname, users, groups, locales, timezone, network, storage

+ state network
    + add internal bridge
    + install and configure nfs-common (and rpcbind) to only listen to internal ip's
        + change pillar list: nfs:listen_ip to overwrite default list

## Example pillar

```yaml
node:
  hostname: myshinyhostname.domain
  users:
    - name: XX
      # additional parameter according to saltstack state.user
      # uid=None, gid=None, usergroup=None, groups=None, optional_groups=None
      # remove_groups=True, home=None, createhome=True
      # password=None, hash_password=False, enforce_password=True, empty_password=False
      # shell=None, unique=True, system=False, fullname=None, roomnumber=None
      # workphone=None, homephone=None, other=None, loginclass=None, date=None
      # mindays=None, maxdays=None, inactdays=None, warndays=None, expire=None,
      # nologinit=False, allow_uid_change=False, allow_gid_change=False

      # additional parameter for ssh access
      # use_authorized_keys: default = false, installs ssh_authorized_keys if true

  groups:
    - name: XX
      # additional parameter according to saltstack state.group
      # gid (str), system (bool), addusers (list), delusers (list), members (list)

  locale:
    lang: de:at
    language: de_DE:de
    additional: de:de en:us en:gb
    posix_messages: true
    timezone: Europe/Vienna
    location: Vienna

    # computed
    # language: de_AT:de # if language is currently empty else keep current
    language_code: de-at
    lang_env: de_AT.UTF-8
    lang_all: de_AT.UTF-8 de_DE.UTF-8 en_US.UTF-8 en_GB.UTF-8
    messages_env: POSIX # POSIX if posix_messages == true else ""

  network:
    internal_cidr: 10.140.250.1/24
    internal_name: resident
    netplan: ""

    # computed
    internal_ip: {{ internal_cidr|regex_replace ('([^/]+)/.+', '\\1') }}
    internal_netcidr: {{ salt['network.convert_cidr'](internal_cidr)['network'] }}
    internal_netmask: {{ salt['network.convert_cidr'](internal_cidr)['netmask'] }}

  storage:
    filesystem:
      zfs:
        - name: rpool/data/volumes
      lvm:
        - name: vg0/ext4data
    mount:
    directory:
      - name: /data/volumes/lxd
        require:
          - zfs: zfs_fs_present_rpool/data/volumes
      - name: /mnt/data/volumes/lxd
        makedirs: true
```
