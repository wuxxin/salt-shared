{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}

{{ apt_add_repository("ansible_ppa", "ansible/ansible") }}

{% endif %}

ansible_nop:
  test:
    - nop
