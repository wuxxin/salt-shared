{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

cogscinl_ppa:
  pkgrepo.managed:
    - ppa: smathot/cogscinl
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

