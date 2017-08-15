{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("haproxy-ppa", "vbernat/haproxy-1.5") }}

{% endif %} 
