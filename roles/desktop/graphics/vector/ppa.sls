{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

inkscape-ppa:
  pkgrepo.managed:
    - ppa: inkscape.dev/stable
    - file: /etc/apt/sources.list.d/inkscape.dev.list
{% endif %} 
