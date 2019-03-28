include:
  - appliance.postgresql
  
# make directories and relocate files
{% load_yaml as custom_storage %}
directory:
  - name: /data
    mountpoint: {{ salt['pillar.get']("appliance:storage:mount:data",false) }}
  - name: /data/postgresql
    user: postgres
    require:
      - file: "directory_/data"
      - pkg: postgresql
  - name: pgdump
    user: app
    require:
      - file: "directory_/data"
      - user: application_user
relocate:
  - source: /var/lib/postgresql
    target: /data/postgresql
    prefix: systemctl stop postgresql
    postfix: systemctl start postgresql
    require:
      - file: "directory_/data/postgresql"
{% endload %}
{{ storage_setup(custom_storage) }}

