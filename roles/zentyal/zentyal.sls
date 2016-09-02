include:
  - .ppa

zentyal:
  pkg.installed:
    - pkgs:
      - zentyal
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

{% for i in salt['pillar.get']('zentyal:languages', []) %}
install_zentyal_language_{{ i }}:
  pkg.installed:
    - name: language-pack-zentyal-{{ i }}

{% endfor %}


zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - pkg: zentyal
