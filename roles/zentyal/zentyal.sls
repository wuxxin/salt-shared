# ### package installation

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
      val: {{ salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"') }}
    - require:
      - pkg: zentyal

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - pkg: zentyal
