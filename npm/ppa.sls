{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

nodejs_ppa:
  pkgrepo.managed:
    - ppa: chris-lea/node.js
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
