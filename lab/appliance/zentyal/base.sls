{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - appliance
  - ubuntu

{# ### templates #}
{# configure templates first, so they are already available on the first template execution run #}

{% for n in ['core/nginx.conf.mas',
  'mail/main.cf.mas', 'mail/dovecot.conf.mas',
  'samba/smb.conf.mas', 'samba/shares.conf.mas'] %}
/etc/zentyal/stubs/{{ n }}:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/stubs/{{ n }}
    - makedirs: true
    - require_in:
      - pkg: zentyal
{% endfor %}

zentyal-requisites:
  pkg.installed:
    - pkgs:
      - bridge-utils
      
samba-network:
  network.managed:
    - name: sambabr0
    - type: bridge
    - enabled: true
    - ports: none
    - proto: static
    - ipaddr: {{ settings.samba.bridge.ipaddr }}
    - netmask: {{ settings.samba.bridge.netmask }}
    - stp: off
    - require:
      - pkg: zentyal-requisites

zentyal:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 5.1 main
    - file: /etc/apt/sources.list.d/zentyal-xenial.list
    - key_url: salt://lab/appliance/zentyal/files/zentyal-5.1-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: zentyal

  pkg.installed:
    - pkgs:
      - zentyal
      - zentyal-groupware
      - zentyal-samba
      - zentyal-mail
      - zentyal-sogo
      - zentyal-antivirus
      - zentyal-mailfilter
{%- if settings.languages %}
{%- for i in settings.languages %}
{%- if i != 'en' %}
      - language-pack-zentyal-{{ i }}
{%- endif %}
{%- endfor %}
{%- endif %}
    - require:
      - sls: appliance
      - network: samba-network

{# XXX workaround for samba AD needing ext_attr security support not available in an lxc/lxd unprivileged container, this will get overwritten on pkg python-samba update #}
patch-ntacls.py:
  file.managed:
    - name: /usr/lib/python2.7/dist-packages/samba/ntacls.py
    - source: salt://lab/appliance/zentyal/files/ntacls.py
    - makedirs: true
  cmd.run:
    - name: rm /usr/lib/python2.7/dist-packages/samba/ntacls.pyc; python2 -c "import compileall; compileall.compile_file('/usr/lib/python2.7/dist-packages/samba/ntacls.py')"
    - onchanges:
      - file: patch-ntacls.py

{%- set password= settings.admin.password or salt['cmd.run_stdout']('openssl rand 8 -hex') %}

zentyal-admin-user:
  user.present:
    - name: {{ settings.admin.user }}
    - groups:
      - adm
      - sudo
    - remove_groups: False
    - password: {{ salt.shadow.gen_password(password) }}

set_os_extra:
  module.run:
    - name: grains.setval
      key: os_extra
      val: zentyal
    - require:
      - pkg: zentyal

