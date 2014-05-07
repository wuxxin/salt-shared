{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

jayatana-ppa:
  pkgrepo.managed:
    - ppa: danjaredg/jayatana

{% endif %} 
