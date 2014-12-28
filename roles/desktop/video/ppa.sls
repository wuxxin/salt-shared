{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

x265-ppa:
  pkgrepo.managed:
    - ppa: strukturag/libde265

{% endif %} 
