{% if (grains['os'] == 'Ubuntu') %}
include:
  - repo.ubuntu

zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 4.2 main
    - key_url: http://keys.zentyal.org/zentyal-4.2-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer

{% endif %}
