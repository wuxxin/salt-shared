{% from "mysql/defaults.jinja" import settings with context %}

prepare-mariadb.service:
  file.managed:
    - name: /etc/systemd/system/prepare-mariadb.service
    - source: salt://mysql/prepare-mariadb.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: prepare-mariadb.service

mariadb_requisites:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-mysqldb

mariadb:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - mariadb-client
    - require:
      - pkg: mariadb_requisites

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
    - repl: bind-address = {{ settings.listen }}
    - append_if_not_found: true
    - require:
      - pkg: mariadb

{# generate all database users #}
{% for user in settings.user %}

  {%- if user.host|d(false) %}
    {%- set hosts= [user.host] %}
  {%- else %}
    {%- set hosts= user.hosts|d(['localhost']) %}
  {%- endif %}

  {%- for host in hosts %}
mariadb_user_{{ user.name }}@{{ host }}:
  mysql_user.present:
    - name: {{ user.name }}
    - host: {{ host }}
    {%- for key,value in user.items() %}
      {%- if key not in ['name', 'host', 'hosts']%}
    - {{ key }}: {{ value }}
      {%- endif %}
    {%- endfor %}
    - require:
      - service: mariadb
  {%- endfor %}
{% endfor %}


{# generate all databases #}
{% for database in settings.database %}
mariadb_database_{{ database.name }}:
  mysql_database.present:
    - name: {{ database.name }}
    - character_set: {{ database.character_set|d(settings.default_character_set) }}
    - collate: {{ database.collate|d(settings.default_collate) }}
  {%- for key,value in database.items() %}
    {%- if key not in ['name', 'character_set', 'collate', 'owner', 'owners', 'grant',] %}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}
    - require:
      - service: mariadb

  {# set owner of databases #}
  {%- if database.owner|d(false) %}
    {%- set owners= [database.owner] %}
  {%- else %}
    {%- set owners= database.owners|d([]) %}
  {%- endif %}
  {%- for owner in owners %}
mariadb_database_{{ database.name }}_owner_{{ owner }}:
  mysql_grants.present:
    - grant: "{{ database.grant|d('all privileges') }}"
    - database: "{{ database.name }}.*"
    - user: {{ owner.split("@")[0] }}
    - host: {{ owner.split("@")[1]|d('localhost') }}
    - require:
      - mysql_database: mariadb_database_{{ database.name }}
  {%- endfor %}
{% endfor %}
