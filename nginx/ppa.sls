{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

nginx_ppa:
  pkgrepo.managed:
    - ppa: nginx/stable
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

