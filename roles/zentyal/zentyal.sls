include:
  - .ppa

{% if (salt['pkg.version']('samba-libs') != "") and
  (salt['pkg.version_cmp'](salt['pkg.version']('samba-libs'), '4:4.3.4-zentyal1') < 0) %}
# update samba libs before zentyal gets installed
update_old_samba_libs:
  pkg.latest:
    - name: samba-libs
    - require:
      - pkgrepo: zentyal_main_ubuntu
    - require_in:
      - pkg: zentyal
{% endif %}

zentyal:
  pkg.installed:
    - pkgs:
      - zentyal
      - zentyal-samba
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

# sss is producing error messages to root if listed on sudoers
/etc/nsswitch.conf:
  file.replace:
    - pattern: |
        ^sudoers:.+sss.*
    - repl: |
        sudoers:        files
    - backup: False
    - append_if_not_found: True
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

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - pkg: zentyal
