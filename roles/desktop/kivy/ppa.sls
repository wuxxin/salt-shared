{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

kivy-ppa:
  pkgrepo.managed:
    - ppa: kivy-team/kivy

{% endif %} 
