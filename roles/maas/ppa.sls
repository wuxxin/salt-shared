{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

maas-ppa:
  pkgrepo.managed:
    - ppa: maas-maintainers/stable

{% endif %} 
