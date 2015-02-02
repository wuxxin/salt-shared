{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

inkscape-ppa:
  pkgrepo.managed:
    - ppa: inkscape.dev/stable

{% endif %} 
