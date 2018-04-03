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
{%- for i in salt['pillar.get']('appliance:zentyal:languages', []) %}
{%- if i != 'en' %}
      - language-pack-zentyal-{{ i }}
{%- endif %}
{%- endfor %}
    - require:
      - sls: appliance

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
