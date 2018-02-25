include:
  - appliance.postgresql
  
# make directories and relocate files
{% load_yaml as custom_storage %}
directory:
  /data:
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:data",false) }}
    parts:
      - name: postgresql
        user: app
      - name: pgdump
        user: app
relocate:
  - source: /var/lib/postgresql
    target: /data/postgresql
    prefix: systemctl stop postgresql
    postfix: systemctl start postgresql
{% endload %}
{{ storage_setup(custom_storage) }}

