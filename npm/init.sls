{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

nodejs_ppa:
  pkgrepo.managed:
    - ppa: chris-lea/node.js
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

nodejs:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: ppa-nodejs
{% endif %}

npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


