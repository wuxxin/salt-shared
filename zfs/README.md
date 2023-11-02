# zfs state

## Features

- autoscrub: cyclic data scrubbing of filesystem
  - if enabled will execute once per month for 4 months, then once every 6 months

- autotrim: cyclic "automatic" manual start of trimming the filesystem
  - if enabled will execute a manual trimming once per month

- autosnapshot: cyclic rotating filesystem snapshots
  - if enabled any fs where "com.sun:auto-snapshot" and "com.sun:auto-snapshot:<interval>"
    is not false, a rotating snapshot will be taken.

- arc_max_limit:
  - if enabled, arc_max_percent will be used to calculate memory available for arc

- default autoscrub and autotrim acts on rpool, for additional pools use eg.
```yaml
zfs:
  autoscrub:
    enabled: true
    pools:
      - rpool
      - dpool
  autotrim:
    enabled: true
    pools:
      - rpool
      - dpool
```

- see `defaults.jinja` for detailed settings

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
