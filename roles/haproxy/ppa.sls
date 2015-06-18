{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

haproxy-ppa:
  pkgrepo.managed:
    - ppa: "vbernat/haproxy-1.5"
    - file: /etc/apt/sources.list.d/vbernat-haproxy.list

{% endif %} 
