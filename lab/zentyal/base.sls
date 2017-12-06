include:
  - appliance
  - .ppa

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
      - sls: appliance

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
