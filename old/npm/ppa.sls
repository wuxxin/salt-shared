{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("nodejs_ppa", "chris-lea/node.js") }}

{% endif %}

nodejs_nop:
  test:
    - nop
