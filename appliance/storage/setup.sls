# setup storage on running appliance, this is called from appliance-prepare
{% from 'storage/lib.sls' import storage_setup with context %}

# call custom storage setup if mount should be setup, but disk is not present
{% if (salt['pillar.get']("appliance:storage:mount:volatile", false) and
      not salt['file.file_exists']('/dev/disk/by-label/volatile')) or
      (salt['pillar.get']("appliance:storage:mount:data", false) and
      not salt['file.file_exists']('/dev/disk/by-label/data')) %}
{{ storage_setup(salt['pillar.get']("appliance:storage:setup", {})) }}
{% endif %}

# create base directory, mount volume on request
{% for dir in ['volatile', 'data'] %}
create_{{ dir }}_directory:
  file.directory:
    - name: /{{ dir }}
  {% if salt['pillar.get']("appliance:storage:mount:"+ dir, false) %}
mount_{{ dir }}_directory:
  mount.mounted:
    - name: /{{ dir }}
    - device: /dev/disk/by-label/{{ dir }}
  {% endif %}
{% endfor %}

# make directories and relocate files
{% load_yaml as custom_storage %}
directory:
  /volatile:
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:volatile",false) }}
    parts:
      - name: docker
      - name: backup-test
        user: app
      - name: duplicity
        user: duplicity
      - name: prometheus
        user: 1000
      - name: alertmanager
        user: 1000
      - name: grafana
        user: 1000
  /data:
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:data",false) }}
    parts:
      - name: etc
        user: app
      - name: ca
        user: app
      - name: pgdump
        user: app
relocate:
  - source: /var/lib/docker
    target: /volatile/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
  - source: /app/.cache/duplicity
    target: /volatile/duplicity
  - source: /app/etc
    target: /data/etc
  - source: /var/lib/postgresql
    target: /data/postgresql
    prefix: systemctl stop postgresql
    postfix: systemctl start postgresql
{% endload %}
{{ storage_setup(custom_storage) }}

