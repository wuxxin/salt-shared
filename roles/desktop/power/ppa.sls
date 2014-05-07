{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

tlp-ppa:
  pkgrepo.managed:
    - ppa: linrunner/tlp

{% endif %} 
