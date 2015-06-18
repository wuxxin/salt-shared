{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

jayatana-ppa:
  pkgrepo.managed:
    - ppa: danjaredg/jayatana

{% endif %} 
