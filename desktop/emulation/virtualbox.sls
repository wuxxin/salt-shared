include:
  - ubuntu

virtualbox:
  pkgrepo.managed:
    - name: deb https://download.virtualbox.org/virtualbox/debian {{ grains['lsb_distrib_codename'] }} contrib
    - key_url: https://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc
    - file: /etc/apt/sources.list.d/virtualbox_ppa.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: virtualbox
  pkg.installed:
    - name:
      - virtualbox-5.2

virtualbox-extpack:
  file.managed:
    - source: https://download.virtualbox.org/virtualbox/5.2.26/Oracle_VM_VirtualBox_Extension_Pack-5.2.26.vbox-extpack
    - source_hash: 4b7caa9b722840d49f154c3e5efb6463b1b7129f09973a25813dfdbccd9debb7
    - name: /usr/local/share/virtualbox/Oracle_VM_VirtualBox_Extension_Pack-5.2.26.vbox-extpack
    - makedirs: true
    - requires:
      - pkg: virtualbox
  cmd.run:
    - name: VBoxManage extpack install --replace /usr/local/share/virtualbox/Oracle_VM_VirtualBox_Extension_Pack-5.2.26.vbox-extpack
    - onchanges:
      - file: virtualbox-extpack
