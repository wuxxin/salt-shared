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

/etc/zfs/zfs-list.cache:
  file.directory:
    - makedirs: True

{% for service in ["zfs-import-cache", "zfs-mount", "zfs.target", "zfs-zed.service"] %}
enable_{{ service }}:
  cmd.run:
    - name: systemctl enable {{ service }}
{% endfor %}

{% for pool in settings.autoscrub.pools %}
zpool-scrub@{{ pool }}.timer:
  cmd.run:
    - name: systemctl {{ 'enable' if settings.autoscrub.enabled == true else 'disable' }} --now zpool-scrub@{{ pool }}.timer
    - require:
      - file: zpool-scrub@.timer
{% endfor %}

{% for pool in settings.autotrim.pools %}
zpool-trim@{{ pool }}.timer:
  cmd.run:
    - name: systemctl {{ 'enable' if settings.autotrim.enabled == true else 'disable' }} --now zpool-trim@{{ pool }}.timer
    - require:
      - file: zpool-trim@.timer
{% endfor %}

{% for label in ['frequent', 'hourly', 'daily', 'weekly', 'monthly'] %}
zfs-snapshot@{{ label }}.timer:
  cmd.run:
    - name: systemctl {{ 'enable' if (settings.autosnapshot.enabled == true and settings.autosnapshot[label] != 0) else 'disable' }} --now zfs-snapshot-{{ label }}.timer
    - require:
      - file: zfs-snapshot-{{ label }}.timer
{% endfor %}
