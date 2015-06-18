{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

ansible_ppa:
  pkgrepo.managed:
    - ppa: ansible/ansible
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

