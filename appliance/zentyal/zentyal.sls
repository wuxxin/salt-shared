include:
  - .ppa
{%- if salt['pillar.get']('letsencrypt:enabled', false) %}
  - letsencrypt
{% endif %}

zentyal:
  pkg.installed:
    - pkgs:
      - zentyal
      - zentyal-samba
      - zentyal-mail
      - zentyal-mailfilter
      - zentyal-openchange
{%- for i in salt['pillar.get']('zentyal:languages', []) %}
      - language-pack-zentyal-{{ i }}
{%- endfor %}
    - require:
      - pkgrepo: zentyal_main_ubuntu

set_os_extra:
  module.run:
    - name: grains.setval
      key: os_extra
      val: zentyal
    - require:
      - pkg: zentyal

set_zentyal_version:
  module.run:
    - name: grains.setval
      key: zentyal_version
      val: {{ salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"', python_shell=True) }}
    - require:
      - pkg: zentyal

zentyal-admin-user:
  user.present:
    - name: {{ pillar.zentyal.admin.user }}
    - groups:
      - adm
      - sudo
    - remove_groups: False
    - password: {{ salt.shadow.gen_password(pillar.zentyal.admin.password) }}

# sss is producing error messages to root if listed on sudoers
/etc/nsswitch.conf:
  file.replace:
    - pattern: |
        ^sudoers:.+sss.*
    - repl: |
        sudoers:        files
    - backup: False
    - append_if_not_found: false
    - require:
      - pkg: zentyal

# ### letsencrypt preperation
{% if salt['pillar.get']('letsencrypt:enabled', false) %}
    {% set domain = salt['pillar.get']('letsencrypt:domains', ['domain.not.set'])[0].split(' ')[0] %}

zentyal-dehydrated-hook:
  file.managed:
    - name: /usr/local/etc/dehydrated/zentyal-dehydrated-hook.sh
    - source: salt://roles/zentyal/files/zentyal-dehydrated-hook.sh
    - mode: "0755"
    - require:
      - sls: letsencrypt

zentyal-apache-reload:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /etc/apache2/conf-available/10-wellknown-acme.conf
    - require:
      - sls: letsencrypt
      - pkg: zentyal

initial-cert-creation:
  cmd.run:
    - name: /usr/local/bin/dehydrated -c
    - unless: test -e /usr/local/etc/dehydrated/certs/{{ domain }}/fullchain.pem
    - require:
      - file: zentyal-dehydrated-hook
      - service: zentyal-apache-reload
      - sls: letsencrypt
          
{% endif %}
