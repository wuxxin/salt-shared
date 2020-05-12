# zfs state

## todo
+ rebase custom-zfs-patches and fix custom-build-zfs

### snippets

#### recreate zfs fs list (for machine-bootstrap)

{%- for item in test %}zfs create
  {%- if item.properties is defined %}
    {%- for key,value in item.properties.items() %} -o "{{ key }}={{ value|replace('True', 'on')|replace('False', 'off') if value is boolean else value }}"{%- endfor %}
  {%- endif %} {{ item.name }}
{% endfor %}

#### list snapshots
zfs list -t snapshot -o name

#### destroy a bunch of snapshots
zfs list -t snapshot -o name | grep "^rpool/data/lxd/.*@zfs-auto-snap" | tac | xargs -n 1 echo zfs destroy -vr

#### list a all auto-snapshot settings (except inherited or unset)
for i in "" ":frequent" ":hourly" ":daily" ":weekly" ":monthly"; do zfs get -Hrp com.sun:auto-snapshot$i rpool ; done | grep -v "inherited from" | grep -vE -- "[[:space:]]+-[[:space:]]+-[[:space:]]*$"
