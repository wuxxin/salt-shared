{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("nginx_ppa", "nginx/stable") }}

{% endif %}

nginx_nop:
  test:
    - nop
