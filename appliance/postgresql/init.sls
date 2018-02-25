include:
  - appliance.base
  - appliance.network
  - systemd.reload

{% from "appliance/postgresql/defaults.jinja" import settings with context %}

/usr/local/share/appliance/postgresql.functions.sh:
  file.managed:
    - source: salt://appliance/postgresql/postgresql.functions.sh
    - template: jinja
    - context: settings

{% for l in [
    ['prepare-storage', 'check', 'postgresql.sh'],
    ['prepare-storage', 'setup', 'postgresql.sh'],
    ['appliance-backup', 'prefix_backup', 'postgresql.sh'],
    ['appliance-backup', 'create_backup_filelist', 'postgresql.sh'],
  ] %}
/app/etc/hooks/{{ l[0] }}/{{ l[1] }}/{{ l[2] }}:
  file.managed:
    - source: salt://appliance/postgresql/{{ l[0] }}-{{ l[1] }}-{{ l[2] }}
{% endfor %}    


appliance-postgresql.service:
  file.managed:
    - name: /etc/systemd/system/appliance-postgresql.service
    - source: salt://appliance/postgresql/appliance-postgresql.service
    - template: jinja
    - context: settings
    - watch_in:
      - cmd: systemd_reload
  cmd.wait:
    - name: systemctl enable appliance-postgresql.service
    - watch:
      - file: appliance-postgres.service

postgresql:
  pkg.installed:
    - pkgs:
      - postgresql
      - postgresql-common
      - postgresql-contrib
      - postgresql-client
  service.running:
    - enable: true
    - require:
      - pkg: postgresql
      - cmd: appliance-postgresql.service
      - sls: appliance.network
      - file: /etc/postgresql/{{ settings.version }}/main/pg_hba.conf
    - watch:
      - file: /etc/postgresql/{{ settings.version }}/main/pg_hba.conf

/etc/postgresql/{{ settings.version }}/main/pg_hba.conf:
  file.replace:
    - pattern: |
        ^host.*{{ salt['pillar.get']('docker:net') }}.*
    - repl: |
        host     all             app             {{ salt['pillar.get']('docker:net') }}           md5
    - append_if_not_found: true
    - require:
      - pkg: postgresql

{% for p,r in settings.iteritems() %}
  {% if p != 'version' %}
/etc/postgresql/{{ settings.version }}/main/postgresql.conf_{{ p }}:
  file.replace:
    - name: /etc/postgresql/{{ settings.version }}/main/postgresql.conf
    - pattern: |
        ^.*{{ p }}.*
    - repl: |
        {{ p }} = {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql
    - require_in:
      - service: postgresql
  {% endif %}
{% endfor %}

