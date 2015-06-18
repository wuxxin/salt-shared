{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

tlp-ppa:
  pkgrepo.managed:
    - ppa: linrunner/tlp

{% endif %} 
