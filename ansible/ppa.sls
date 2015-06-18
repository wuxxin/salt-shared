{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

ansible_ppa:
  pkgrepo.managed:
    - ppa: ansible/ansible
    - file: /etc/apt/sources.list.d/ansible.list
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

