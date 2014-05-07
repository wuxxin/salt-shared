{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

haproxy-ppa:
  pkgrepo.managed:
    - ppa: "vbernat/haproxy-1.5"

{% endif %} 
