include:
  - ubuntu

virtualbox:
  pkgrepo.managed:
    - name: deb https://download.virtualbox.org/virtualbox/debian {{ grains['lsb_distrib_codename'] }} contrib
    - key_url: https://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: virtualbox
  pkg.installed:
    - name:
      - virtualbox-5.2

virtualbox-extpack:
  file.managed:
    - source: https://download.virtualbox.org/virtualbox/5.2.8/Oracle_VM_VirtualBox_Extension_Pack-5.2.8.vbox-extpack
    - source_hash: 355ea5fe047f751534720c65398b44290d53f389e0f5f66818f3f36746631d26
    - name: /usr/local/share/virtualbox/Oracle.vbox-extpack
    - requires:
      - pkg: virtualbox
  cmd.run:
    - name: VBoxManage extpack install --replace /usr/local/share/virtualbox/Oracle.vbox-extpack
    - onchanges:
      - file: virtualbox-extpack
