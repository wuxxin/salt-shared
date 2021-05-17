# zfs state

## todo

+ implement non linear scrub
  + for 6 weeks every 14days on sunday
  + then every 6 months
  + default: Scrub the second Sunday of every month.
      +  24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub

+ remake custom-build-zfs

### snippets

#### recreate zfs fs list (for machine-bootstrap)
```jinja
{%- for item in test %}zfs create
  {%- if item.properties is defined %}
    {%- for key,value in item.properties.items() %} -o "{{ key }}={{ value|replace('True', 'on')|replace('False', 'off') if value is boolean else value }}"{%- endfor %}
  {%- endif %} {{ item.name }}
{% endfor %}
```

#### list snapshots
`zfs list -t snapshot -o name`

#### destroy a bunch of snapshots
```bash
zfs list -t snapshot -o name \
  | grep "^rpool/data/lxd/.*@zfs-auto-snap" \
  | tac | xargs -n 1 echo zfs destroy -vr
```

### list a all auto-snapshot settings (except inherited or unset)
```bash
for i in "" ":frequent" ":hourly" ":daily" ":weekly" ":monthly"; do
  zfs get -Hrp com.sun:auto-snapshot$i rpool
done | grep -v "inherited from" | grep -vE -- "[[:space:]]+-[[:space:]]+-[[:space:]]*$"
```

### customize zfs build

if zfs:custom-build:enabled: true
+ test which customized zfs we have in custom archive
+ if there is a newer version (or not installed so far)
    + build and update running system
    + reinstall packages "zfsutils-linux zfs-dkms" after custom build
    + update recovery-squashfs

```jinja
{% for f in ['build_from_lp.sh', 'customize-running-system.sh'] %}
/etc/recovery/zfs/{{ f }}:
  file.managed:
    - source: salt://machine-bootstrap/{{ f }}
    - filemode: "0755"
    - makedirs: true
{% endfor %}
```

#### write out zfs patches somewhere ?

+ https://github.com/vpsfreecz/zfs/tree/vpsadminos-master-2004060

```jinja
{% for p in salt['cmd.run_stdout'](
  'find '+ grains['project_basepath']+
    '/machine-bootstrap/zfs/ -name "*.patch" -type f -printf "%f\n" | sort -n',
  python_shell=True) %}
/etc/recovery/zfs/{{ p }}
  file.managed:
    - source: salt://machine-bootstrap/zfs/{{ p }}
{% endfor %}
```
