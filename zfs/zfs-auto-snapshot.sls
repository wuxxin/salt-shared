{% load_yaml as defaults %}
args: --quiet --syslog --default-exclude --fast --skip-scrub
{# --min-size 1 #}
{# only in github version: 
https://github.com/zfsonlinux/zfs-auto-snapshot/commit/27413ac7983ca9ed22af111f64268cbe376078d7
#}
{#
15min   intervals for the last  2 hours
 1hour  intervals for the last 12 hours
 1day   intervals for the last 14 days
 1week  intervals for the last  4 weeks
 1month intervals for the last  4 months
#}
keep:
  frequent: 8
  hourly: 12
  daily: 14
  weekly: 4
  monthly: 4
{% endload %}

{% set settings=salt['grains.filter_by']({'none': defaults},
  grain='none', default= 'none', merge= salt['pillar.get']('zfs:auto-snapshot', {})) %}

zfs-auto-snapshot:
  pkg:
    - installed

/etc/cron.d/zfs-auto-snapshot:
  file.managed:
    - contents: |
        PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
        */15 * * * * root which zfs-auto-snapshot > /dev/null || exit 0 ; zfs-auto-snapshot {{ settings.args }} --label=frequent --keep={{ settings.keep.frequent }} //

{% for label,value in settings.keep.items() %}
  {% if label != 'frequent' %}
/etc/cron.{{ label }}/zfs-auto-snapshot:
  file.managed:
    - mode: "0755"
    - contents: |
        #!/bin/sh
        # Only call zfs-auto-snapshot if it's available
        which zfs-auto-snapshot > /dev/null || exit 0
        exec zfs-auto-snapshot {{ settings.args }} --label={{ label }} --keep={{ value }} //
  {% endif %}
{% endfor %}

{#

### snippets

# list snapshots
zfs list -t snapshot -o name

# destroy a bunch of snapshots
zfs list -t snapshot -o name | grep "^rpool/data/lxd/.*@zfs-auto-snap" | tac | xargs -n 1 echo zfs destroy -vr
  
# list a all auto-snapshot settings (except inherited or unset)
for i in "" ":frequent" ":hourly" ":daily" ":weekly" ":monthly"; do zfs get -Hrp com.sun:auto-snapshot$i rpool ; done | grep -v "inherited from" | grep -vE -- "[[:space:]]+-[[:space:]]+-[[:space:]]*$"

#}
