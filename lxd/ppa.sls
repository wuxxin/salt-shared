{% if (grains['os'] == 'Ubuntu') %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("lxd_stable_ppa", "ubuntu-lxc/lxd-stable ") }}

{% endif %}
