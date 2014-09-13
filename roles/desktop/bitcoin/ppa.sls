{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

bitcoin-ppa:
  pkgrepo.managed:
    - ppa:bitcoin/bitcoin

{% endif %} 
