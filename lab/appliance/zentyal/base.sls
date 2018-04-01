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

zentyal-admin-user:
  user.present:
    - name: {{ pillar.appliance.zentyal.admin.user }}
    - groups:
      - adm
      - sudo
    - remove_groups: False
    - password: {{ salt.shadow.gen_password(pillar.appliance.zentyal.admin.password) }}

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
