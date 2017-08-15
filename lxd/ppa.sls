{% if (grains['os'] == 'Ubuntu') %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("lxd_stable_ppa", "ubuntu-lxc/lxd-stable ") }}

{% endif %}

lxd_nop:
  test:
    - nop
