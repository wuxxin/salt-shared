{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
golang_ppa:
  pkgrepo.managed:
    - ppa: ubuntu-cloud-archive/cloud-tools-next
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
