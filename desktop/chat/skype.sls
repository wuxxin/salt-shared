include:
  - ubuntu

skype:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://repo.skype.com/deb stable main
    - key_url: https://repo.skype.com/data/SKYPE-GPG-KEY
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: skype

  pkg.installed:
    - name: skypeforlinux
