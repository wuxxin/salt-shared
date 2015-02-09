{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 


{% if grains['os'] == 'Ubuntu' %}
recoll_ppa:
  pkgrepo.managed:
    - ppa: recoll-backports/recoll-1.15-on
{% endif %}

