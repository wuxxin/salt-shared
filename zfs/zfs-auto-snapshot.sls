{% load_yaml as defaults %}
args: --quiet --syslog --default-exclude --fast
keep:
  frequent: 4
  hourly: 24
  daily: 31
  weekly: 8
  monthly: 12
{% endload %}

{% set settings=salt['grains.filter_by']({'none': defaults},
  grain='none', default= 'none', merge= salt['pillar.get']('zfs-auto-snapshot', {})) %}

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
