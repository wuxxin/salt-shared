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
  cmd.run:
    - name: systemctl {{ 'enable' if settings.autoscrub == true else 'disable' }} --now zpool-scrub@{{ pool }}.timer
    - require:
      - file: zpool-scrub@.timer

zpool-trim@{{ pool }}.timer:
  cmd.run:
    - name: systemctl {{ 'enable' if settings.autotrim == true else 'disable' }} --now zpool-trim@{{ pool }}.timer
    - require:
      - file: zpool-trim@.timer

  {% for label in ['frequent', 'hourly', 'daily', 'weekly', 'monthly'] %}
zfs-snapshot-{{ label }}@rpool.timer:
  cmd.run:
    - name: systemctl {{ 'enable' if (settings.autosnapshot == true and settings.snapshot[label] != 0) else 'disable' }} --now zfs-snapshot-{{ label }}@rpool.timer
    - require:
      - file: zfs-snapshot-{{ label }}@.timer
  {% endfor %}

{% endfor %}
