include:
  - ubuntu

zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 5.0 main
    - key_url: http://keys.zentyal.org/zentyal-5.0-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
