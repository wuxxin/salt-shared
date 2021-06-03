{% from "backup/defaults.jinja" import settings with context %}

{% set rclone_local_binary= "/usr/local/bin/rclone" %}
{% set restic_local_binary= "/usr/local/bin/restic" %}

restic_req:
  pkg.installed:
    - pkgs:
      - bzip2
      - unzip
      - fuse

restic:
  file.managed:
    - source: {{ settings.external['restic_bz2']['download'] }}
    - source_hash: sha256={{ settings.external['restic_bz2']['hash'] }}
    - name: {{ settings.external['restic_bz2']['target'] }}
    - require:
      - pkg: restic_req
  cmd.run:
    - name: bzip2 -d < {{ settings.external['restic_bz2']['target'] }} > {{ restic_local_binary }}
    - onchanges:
      - file: restic
restic_binary:
  file.managed:
    - name: {{ restic_local_binary }}
    - mode: "0755"
    - replace: False
    - require:
      - cmd: restic

rclone:
  file.managed:
    - source: {{ settings.external['rclone_zip']['download'] }}
    - source_hash: sha256={{ settings.external['rclone_zip']['hash'] }}
    - name: {{ settings.external['rclone_zip']['target'] }}
    - require:
      - pkg: restic_req
  cmd.run:
    - name: unzip -q -j -o -d /usr/local/bin \
            {{ settings.external['rclone_zip']['target'] }} \
            rclone-v{{ settings.external['rclone_zip']['version']-linux-amd64/rclone
    - onchanges:
      - file: rclone
rclone_binary:
  file.managed:
    - name: {{ rclone_local_binary }}
    - mode: "0755"
    - replace: False
    - require:
      - cmd: rclone
