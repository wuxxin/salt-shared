{% from "app/defaults.jinja" import system_main with context %}

{% set rclone_local_download= "/usr/local/"+ system_main.rclone_zip.target+ "/rclone_zip" %}
{% set restic_local_download= "/usr/local/"+ system_main.restic_bz2.target+ "/restic_bz2" %}
{% set rclone_local_binary= "/usr/local/bin/rclone" %}
{% set restic_local_binary= "/usr/local/bin/restic" %}

restic_req:
  pkg.installed:
    - pkgs:
      - bzip2
      - unzip
      - fuse

rclone:
  file.managed:
    - name: {{ rclone_local_download }}
    - source: {{ system_main.rclone_zip.download }}
    - source_hash: sha256={{ system_main.validate.rclone_zip }}
    - require:
      - pkg: restic_req
  cmd.run:
    - name: unzip -q -j -o -d /usr/local/bin {{ rclone_local_download }} rclone-v{{ system_main.rclone_zip.version }}-linux-amd64/rclone
    - onchanges:
      - file: rclone
rclone_binary:
  file.managed:
    - name: {{ rclone_local_binary }}
    - mode: "0755"
    - replace: False
    - require:
      - cmd: rclone

restic:
  file.managed:
    - name: {{ restic_local_download }}
    - source: {{ system_main.restic_bz2.download }}
    - source_hash: sha256={{ system_main.validate.restic_bz2 }}
    - require:
      - pkg: restic_req
  cmd.run:
    - name: bzip2 -d < {{ restic_local_download }} > {{ restic_local_binary }}
    - onchanges:
      - file: restic
restic_binary:
  file.managed:
    - name: {{ restic_local_binary }}
    - mode: "0755"
    - replace: False
    - require:
      - cmd: restic
