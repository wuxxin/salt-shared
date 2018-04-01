include:
  - appliance
  - ubuntu

zentyal:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 5.1 main
    - key_url: salt://lab/appliance/zentyal/files/zentyal-5.1-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: zentyal

  pkg.installed:
    - pkgs:
      - zentyal
      - zentyal-groupware
      - zentyal-mail
      - zentyal-sogo
      - zentyal-antivirus
      - zentyal-mailfilter
{%- for i in salt['pillar.get']('appliance:zentyal:languages', []) %}
{%- if i != 'en' %}
      - language-pack-zentyal-{{ i }}
{%- endif %}
{%- endfor %}
    - require:
      - sls: appliance

zentyal-admin-user:
  user.present:
    - name: {{ pillar.appliance.zentyal.admin.user }}
    - groups:
      - adm
      - sudo
    - remove_groups: False
    - password: {{ salt.shadow.gen_password(pillar.appliance.zentyal.admin.password) }}

set_os_extra:
  module.run:
    - name: grains.setval
      key: os_extra
      val: zentyal
    - require:
      - pkg: zentyal

{# XXX only works on next run, because jinja is evaluated before state run #}
set_zentyal_version:
  module.run:
    - name: grains.setval
      key: zentyal_version
      val: {{ salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"', python_shell=True) }}
    - require:
      - pkg: zentyal

{# XXX workaround missing enabled proxy modul, zentyal setup expects this #}
{% for i in ['proxy.conf', 'proxy.load'] %}
zentyal-apache-enable-{{ i }}:
  file.symlink:
    - name: /etc/apache2/mods-enabled/{{ i }}
    - target: ../mods-available/{{ i }}
    - watch_in:
      - service: zentyal-apache-restart-proxymod
{% endfor %}

zentyal-apache-restart-proxymod:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: zentyal

{# XXX workaround not resolving salt master after zentyal internal dns installation, add salt to /etc/hosts #}
{% if grains['master'] != '' %}
  {% set saltshort = grains['master'] %}
  {% for domain in salt['grains.get']('dns:search') %}
    {% set saltmaster = saltshort+ "."+ domain %}
    {% set saltip = salt['dnsutil.A'](saltmaster) %}
    {% if saltip is iterable and saltip is not string and saltip[0] != '' %}
adding-salt-master-to-hosts:
  file.replace:
    - name: /etc/hosts
    - append_if_not_found: true
    - pattern: |
        ^.*{{ saltshort }}.*{{ saltshort }}.*
  
    - repl: |
        {{ saltip[0] }} {{ saltmaster }} {{ saltshort }}
  
    {% endif %}
  {% endfor %}
{% endif %}

{# disable warning flooding logs #}
sogo-tmpreaper:
  file.replace:
    - name: /etc/tmpreaper.conf
    - pattern: |
        ^.*SHOWWARNING=.*
    - repl: |
        SHOWWARNING=false

    - append_if_not_found: true
    - backup: false
    - require:
      - pkg: zentyal
