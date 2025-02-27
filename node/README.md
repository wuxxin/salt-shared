# Node state

Configures hostname, users, groups, locales, location, network, storage

+ .locale
  + configure language, messages, timezone, location
+ .network
  + add netplan.yaml or systemd.netdev/network files if present in pillar
  + add internal bridge (uses networkmanager, netplan, systemd or ifup depending avaiability)
  + configure nsswitch.conf@hosts line for dns name lookup order
+ .hostname
  + Configures hostname
+ .accounts
  + Configure users and groups
+ .storage
  + configure filesystems, mounts and directories

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
    lang: de_AT.UTF-8
    # additional_lang: space seperated list of lang entries (without .UTF-8)
    additional_lang: de_DE en_US en_GB
    # if messages is set, it will be written to LC_MESSAGES, eg.: messages: POSIX
    messages: POSIX
    language: de_de:de
    # keymap: keymap of keyboard
    keymap: de-latin1
    hypen: de en-gb en-us
    spell: de-at de-de en-gb en-us

    # timezone: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    timezone: Europe/Vienna
    # metric for Metric, imperial for Imperial
    unit_system: metric

    city: Vienna
    country_code: AT
    # latitude+longitude+elevation=Stephansdom/Vienna
    latitude: 48.20849
    longitude: 16.37315
    # Altitude above sea level in meters
    elevation: 172

  network:
    internal:
      cidr: 10.140.250.1/24
      name: internal
      # computed if empty:
      # ip, netcidr, netmask, reverse_net, short_net
    netplan: ""
    systemd: ""
    nsswitch:
      hosts: mymachines mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns

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
