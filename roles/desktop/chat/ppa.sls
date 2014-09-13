{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

whatsapp-ppa:
  pkgrepo.managed:
    - ppa: whatsapp-purple/ppa

{% endif %} 
