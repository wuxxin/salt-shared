# zfs state

## Features

- **autoscrub**: cyclic data scrubbing of filesystem
  - if enabled will execute once per month for 4 months, then once every 6 months

- **autotrim**: cyclic "automatic" manual start of trimming the filesystem
  - if enabled will execute a manual trimming once per month

- **autosnapshot**: cyclic rotating filesystem snapshots
  - if enabled any fs where "com.sun:auto-snapshot" and "com.sun:auto-snapshot:<interval>"
    is not false, a rotating snapshot will be taken.
    - supported intervals are: frequent (15min), hourly, daily, weekly, monthly

- **arc_max_limit**:
  - if enabled, arc_max_percent will be used to calculate memory available for arc

## Configuration

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
  autosnapshot:
    enabled: true
```

- as default, none of the features is enabled, you must enable them in the pillar.
  - just including the zfs state **will not run** autoscrub, autotrim and autosnapshot.
- rpool is the only default target for autoscrub and autotrim. define rpool and additional pools if needed.
- see `defaults.jinja` for detailed settings

### snippets

#### list snapshots without header

`zfs list -H -t snapshot -o name`

### list all auto-snapshot settings (except inherited or unset)

```bash
for i in "" ":frequent" ":hourly" ":daily" ":weekly" ":monthly"; do
  zfs get -Hrp com.sun:auto-snapshot$i rpool
done | grep -v "inherited from" | grep -vE -- "[[:space:]]+-[[:space:]]+-[[:space:]]*$"
```

#### recreate zfs fs list (for machine-bootstrap)

```jinja
{%- for item in test %}zfs create
  {%- if item.properties is defined %}
    {%- for key,value in item.properties.items() %} -o "{{ key }}={{ value|replace('True', 'on')|replace('False', 'off') if value is boolean else value }}"{%- endfor %}
  {%- endif %} {{ item.name }}
{% endfor %}
```
