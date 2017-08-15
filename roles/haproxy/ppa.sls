{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("haproxy-ppa", "vbernat/haproxy-1.5") }}

{% endif %} 

haproxy_nop:
  test:
    - nop
