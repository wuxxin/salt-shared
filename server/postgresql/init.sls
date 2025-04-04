{% from "server/postgresql/defaults.jinja" import settings with context %}

/usr/local/bin/pgtune.sh:
  file.managed:
    - source: salt://server/postgresql/pgtune.sh
    - mode: "0755"

prepare-postgresql.service:
  file.managed:
    - name: /etc/systemd/system/prepare-postgresql.service
    - source: salt://server/postgresql/prepare-postgresql.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: prepare-postgresql.service

/etc/systemd/system/postgresql@{{ settings.pgmajor }}-main.service.d/limits.conf:
  file:
{%- if settings.pgtune.enabled and settings.pgtune.cores not in ['all', '', '0', '-1', 0, -1] %}
    - managed
    - makedirs: true
    - contents: |
        [Service]
        AllowedCPUs=0-{{ settings.pgtune.cores - 1 }}
{%- else %}
    - absent
{%- endif %}
    - watch_in:
      - service: postgresql

postgresql:
  pkg.installed:
    - pkgs:
      - postgresql
      - postgresql-{{ settings.pgmajor }}
      - postgresql-contrib
  service.running:
    - enable: true
    - require:
      - pkg: postgresql
      - file: prepare-postgresql.service
    - watch:
      - file: /etc/postgresql/{{ settings.pgmajor }}/main/pg_hba.conf
      - file: /etc/postgresql/{{ settings.pgmajor }}/main/postgresql.conf

{% set ns = namespace(listen = 'localhost') %}

{% if settings.additional_adresses %}
  {% for addr in settings.additional_adresses  %}
    {% if addr.listen is defined %}
      {% set new_listen = ns.listen+ ','+ addr.listen %}
      {% set ns.listen = new_listen %}
    {% endif %}
  {% endfor %}

  {% for listen_answer in settings.additional_adresses %}
"postgresql_{{ settings.pgmajor }}_pg_hba_{{ listen_answer.answer }}":
  file.replace:
    - name: /etc/postgresql/{{ settings.pgmajor }}/main/pg_hba.conf
    - pattern: |
        ^host.*{{ listen_answer.answer }}.*
    - repl: |
        host    all             all             {{ listen_answer.answer }}          md5
    - append_if_not_found: true
    - require:
      - pkg: postgresql
  {% endfor %}
{%- endif %}

{% set p="listen_addresses" %}
{% set r="listen_addresses = '" ~ ns.listen ~ "'" %}
/etc/postgresql/{{ settings.pgmajor }}/main/postgresql.conf_{{ p }}:
  file.replace:
    - name: /etc/postgresql/{{ settings.pgmajor }}/main/postgresql.conf
    - pattern: |
        ^.*{{ p }}.*
    - repl: |
        {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql
    - require_in:
      - service: postgresql

{% for extension in settings.extensions %}
{{ extension }}_postgresql_extension:
  postgres_extension.present:
    - name: {{ extension }}
    - require:
      - service: postgresql
{% endfor %}

{% for user in settings.user %}
pg_user_{{ user.name }}:
  postgres_user.present:
    - name: {{ user.name }}
    - login: {{ user.login|d('true') }}
    - encrypted: {{ user.encrypted|d('true') }}
  {%- for key,value in user.items() %}
    {%- if key not in ['name', 'login', 'encrypted']%}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}
    - require:
      - service: postgresql
{% endfor %}

{% for database in settings.database %}
pg_database_{{ database.name }}:
  postgres_database.present:
    - name: {{ database.name }}
    - encoding: {{ database.encoding|d(settings.default_encoding) }}
    - template: {{ database.template|d(settings.default_template) }}
  {%- for key,value in database.items() %}
    {%- if key not in ['name', 'encoding', 'template', 'extensions']%}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}
    - require:
      - service: postgresql
  {% if database.extensions is defined %}
    {% for ext in database.extensions %}
{{ ext }}_pg_database_{{ database.name }}:
  postgres_extension.present:
    - name: {{ ext }}
    - maintenance_db: {{ database.name }}
    - require:
      - postgres_database: {{ database.name }}
    {% endfor %}
  {%- endif %}
{% endfor %}
