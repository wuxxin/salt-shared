{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

cogscinl_ppa:
  pkgrepo.managed:
    - ppa: smathot/cogscinl
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

