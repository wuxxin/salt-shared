include:
  - appliance.base
  - appliance.network
  - systemd.reload

{% from "appliance/mysql/defaults.jinja" import settings with context %}

{% if grains['osrelease_info'][0]|int < 16 %}
  {% set keyid="0xcbcb082a1bb943db" %}
{% else %}
  {% set keyid="0xF1656F24C74CD1D8" %}
{% endif %}

pkgrepo.managed:
  - name: deb http://ppa.launchpad.net/wolfnet/logstash/ubuntu precise main
  - keyid: {{ keyid }}
  - keyserver: keyserver.ubuntu.com
  - name: deb [arch=amd64,i386] http://mirror.klaus-uwe.me/mariadb/repo/{{ settings.version }}/ubuntu {{ grains.oscodename }} main
  - require_in:
    - pkg: mariadb
{% endif %}

/usr/local/share/appliance/mariadb.functions.sh:
  file.managed:
    - source: salt://appliance/mysql/mariadb.functions.sh
    - template: jinja
    - context: settings

{% for l in [
    ['prepare-storage', 'check', 'mariadb.sh'],
    ['prepare-storage', 'setup', 'mariadb.sh'],
    ['appliance-backup', 'prefix_backup', 'mariadb.sh'],
    ['appliance-backup', 'create_backup_filelist', 'mariadb.sh'],
  ] %}
/app/etc/hooks/{{ l[0] }}/{{ l[1] }}/{{ l[2] }}:
  file.managed:
    - source: salt://appliance/mysql/{{ l[0] }}-{{ l[1] }}-{{ l[2] }}
{% endfor %}    

appliance-mariadb.service:
  file.managed:
    - name: /etc/systemd/system/appliance-mariadb.service
    - source: salt://appliance/mysql/appliance-mariadb.service
    - template: jinja
    - context: settings
    - watch_in:
      - cmd: systemd_reload
  cmd.wait:
    - name: systemctl enable appliance-mariadb.service
    - watch:
      - file: appliance-mariadb.service

mariadb:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - mariadb-common
      - mariadb-client
  service.running:
    - enable: true
    - require:
      - pkg: mariadb
      - cmd: appliance-mariadb.service
      - sls: appliance.network
      - file: /etc/mariadb/{{ settings.version }}/main/pg_hba.conf
    - watch:
      - file: /etc/mariadb/{{ settings.version }}/main/pg_hba.conf

/etc/mariadb/{{ settings.version }}/main/pg_hba.conf:
  file.replace:
    - pattern: |
        ^host.*{{ salt['pillar.get']('docker:net') }}.*
    - repl: |
        host     all             app             {{ salt['pillar.get']('docker:net') }}           md5
    - append_if_not_found: true
    - require:
      - pkg: mariadb

{% for p,r in settings.iteritems() %}
  {% if p != 'version ' %}
/etc/mariadb/{{ settings.version }}/main/mariadb.conf_{{ p }}:
  file.replace:
    - name: /etc/mariadb/{{ settings.version }}/main/mariadb.conf
    - pattern: |
        ^.*{{ p }}.*
    - repl: |
        {{ p }} = {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: mariadb
    - watch_in:
      - service: mariadb
    - require_in:
      - service: mariadb
  {% endif %}
{% endfor %}

