{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

knot-ppa:
  pkgrepo.managed:
    - ppa: cz.nic-labs/knot-dns

{% endif %} 
