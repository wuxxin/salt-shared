{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

knot-ppa:
  pkgrepo.managed:
    - ppa: cz.nic-labs/knot-dns

{% endif %} 
