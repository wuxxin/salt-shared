{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
recoll_ppa:
  pkgrepo.managed:
    - ppa: recoll-backports/recoll-1.15-on
{% endif %}

