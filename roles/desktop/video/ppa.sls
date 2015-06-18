{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

x265-ppa:
  pkgrepo.managed:
    - ppa: strukturag/libde265
    - file: /etc/apt/sources.list.d/strukturag-libde265.list

{% endif %} 
