{% from "zfs/defaults.jinja" import settings with context %}

{# --min-size only available from github master #}
{% set calling_args = '--quiet --syslog --default-exclude --fast --skip-scrub --min-size 1' %}
{% set commitid = 'f938d9cc1c414a54a1ee8d638cea7d0ba388ea1a' %}
{% set download_hash = '70d1974c21d50f43dd0dd768544fae42302489fb2d6e42d77973b77e15056967' %}
{% set download_url = 'https://raw.githubusercontent.com/zfsonlinux/zfs-auto-snapshot/'+
    commitid+ '/src/zfs-auto-snapshot.sh' %}

{# remove system version of package, use github version, script selfsustained #}
zfs-auto-snapshot:
  pkg:
    - absent

{# snapshot from commit f938d9cc1c414a54a1ee8d638cea7d0ba388ea1a #}
/usr/local/sbin/zfs-auto-snapshot.sh:
  file.managed:
    - source: {{ download_url }}
    - source_hash: sha256={{ download_hash }}
    - mode: "755"

/etc/cron.d/zfs-auto-snapshot:
  file.managed:
    - contents: |
        PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
        */15 * * * * root which zfs-auto-snapshot > /dev/null || exit 0 ; zfs-auto-snapshot {{ settings.args }} --label=frequent --keep={{ settings.keep.frequent }} //

{% for label in ['hourly', 'daily', 'weekly', 'monthly'] %}
  {% set value = settings['keep_'+label] %}
/etc/cron.{{ label }}/zfs-auto-snapshot:
  file.managed:
    - mode: "0755"
    - contents: |
        #!/bin/sh
        # Only call zfs-auto-snapshot if it's available
        which zfs-auto-snapshot > /dev/null || exit 0
        exec zfs-auto-snapshot {{ calling_args }} --label={{ label }} --keep={{ value }} //
{% endfor %}
