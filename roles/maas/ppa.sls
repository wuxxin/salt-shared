{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

maas-ppa:
  pkgrepo.managed:
    - ppa: maas-maintainers/stable

{% endif %} 
