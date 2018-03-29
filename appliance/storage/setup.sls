include:
  - appliance.base
  
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
  - name: /volatile
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:volatile",false) }}
    require_in:
      - file: "directory_/volatile/docker"
      - file: "directory_/volatile/backup-test"
      - file: "directory_/volatile/duplicity"
      - file: "directory_/volatile/prometheus"
      - file: "directory_/volatile/alertmanager"
      - file: "directory_/volatile/grafana"
  - name: /volatile/docker  
  - name: /volatile/backup-test
    user: app
  - name: /volatile/duplicity
    user: duplicity
  - name: /volatile/prometheus
    user: 1000
  - name: /volatile/alertmanager
    user: 1000
  - name: /volatile/grafana
    user: 1000
    
  - name: /data:
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:data",false) }}
    require_in:
      - file: "directory_/data/etc"
      - file: "directory_/data/app"
      - file: "directory_/data/ca"
      - file: "directory_/data/pgdump"
  - name: /data/etc
    user: app
  - name: /data/ca
    user: app
  - name: /data/pgdump
    user: app
    
relocate:
  - source: /var/lib/docker
    target: /volatile/docker
    prefix: if test -n $(docker ps -q); then docker kill $(docker ps -q); fi; systemctl stop docker
    postfix: systemctl start docker
    require:
      - file: "directory_/volatile/docker"
  - source: /app/.cache/duplicity
    target: /volatile/duplicity
    require:
      - file: "directory_/volatile/duplicity"
  - source: /app/etc
    target: /data/etc
    require:
      - file: "directory_/data/etc"
{% endload %}
{{ storage_setup(custom_storage) }}

{% for i in ['volatile', 'data'] %}
create_{{ i }}_ready:
  file.touch:
    - name: /{{ i }}/storage.ready
{% endfor %}
