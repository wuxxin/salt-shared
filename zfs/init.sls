{% from "zfs/defaults.jinja" import settings with context %}

include:
  - zfs.autoscrub
  - zfs.autotrim
  - zfs.autosnapshot

zfs-utils:
  pkg:
    - installed

/etc/modprobe.d/zfs.conf:
  file:
{% if settings.arc_max_limit == true %}
    - managed
    - contents: |
        options zfs zfs_arc_max={{ settings.arc_max_bytes }}
{% else %}
    - absent
{% endif %}

{% for pool in settings.pools %}

zpool-scrub@{{ pool }}.timer:
  service:
    - {{ 'enabled' if settings.autoscrub == true else 'disabled' }}
    - require:
      - file: zpool-scrub@.timer

zpool-trim@{{ pool }}.timer:
  service:
    - {{ 'enabled' if settings.autotrim == true else 'disabled' }}
    - require:
      - file: zpool-trim@.timer

  {% for label in ['frequent', 'hourly', 'daily', 'weekly', 'monthly'] %}
zfs-snapshot-{{ label }}@rpool.timer:
  service:
    - {{ 'enabled' if (settings.autosnapshot == true and settings.snapshot[label] != 0) else 'disabled' }}
    - require:
      - file: zfs-snapshot-{{ label }}@.timer
  {% endfor %}

{% endfor %}
