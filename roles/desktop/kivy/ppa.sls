{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

kivy-ppa:
  pkgrepo.managed:
    - ppa: kivy-team/kivy

{% endif %} 
