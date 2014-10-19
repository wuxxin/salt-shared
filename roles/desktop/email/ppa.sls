{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

yorba-ppa:
  pkgrepo.managed:
    - ppa: yorba/ppa

{% endif %} 
