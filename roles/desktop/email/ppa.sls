{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

yorba-ppa:
  pkgrepo.managed:
    - ppa: yorba/ppa
    - file: /etc/apt/sources.list.d/yorba.list

{% endif %} 
