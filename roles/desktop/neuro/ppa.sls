{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

cogscinl_ppa:
  pkgrepo.managed:
    - ppa: smathot/cogscinl
    - file: /etc/apt/sources.list.d/smathot-cogscinl.list
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

