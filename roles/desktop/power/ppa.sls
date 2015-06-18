{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

tlp-ppa:
  pkgrepo.managed:
    - ppa: linrunner/tlp
    - file: /etc/apt/sources.list.d/linrunnner-tlp.list
{% endif %} 
