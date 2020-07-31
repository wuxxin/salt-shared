{% from "mysql/defaults.jinja" import settings with context %}

prepare-mariadb.service:
  file.managed:
    - name: /etc/systemd/system/prepare-mariadb.service
    - source: salt://mariadb/prepare-mariadb.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: prepare-mariadb.service

mariadb:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - mariadb-client
  service.running:
    - enable: true
    - watch:
      - file: /etc/mysql/mariadb.conf.d/50-server.cnf
    - require:
      - pkg: mariadb
      - file: prepare-mariadb.service

/etc/mysql/mariadb.conf.d/50-server.cnf:
  file.replace:
    - pattern: ^bind-address.*
    - repl: bind-address = 127.0.0.1
    - append_if_not_found: true
    - require:
      - pkg: mariadb

{% for user in settings.user %}
mariadb_user_{{ user.name }}:
  mysql_user.present:
    - name: {{ user.name }}
  {%- for key,value in user.items() %}
    {%- if key not in ['name',]%}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}
    - require:
      - service: mariadb
{% endfor %}

{% for database in settings.database %}
mariadb_database_{{ database.name }}:
  mysql_database.present:
    - name: {{ database.name }}
    - character_set: {{ database.character_set|d(settings.character_set) }}
    - collate: {{ database.collate|d(settings.collate) }}
  {%- for key,value in database.items() %}
    {%- if key not in ['name', 'character_set', 'collate', 'owner', 'grant'] %}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}
    - require:
      - service: mariadb
  {%- if database.owner is defined %}
mariadb_database_owner_{{ database.name }}:
  mysql_grants.present:
    - grant: "{{ database.grant|d('all privileges') }}"
    - database: "{{ database.name }}.*"
    - user: {{ database.owner }}
    - require:
      - mysql_database: mariadb_database_{{ database.name }}
  {%- endif %}
{% endfor %}
