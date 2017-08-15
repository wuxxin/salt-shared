{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("nginx_ppa", "nginx/stable") }}

{% endif %}

nginx_nop:
  test:
    - nop
