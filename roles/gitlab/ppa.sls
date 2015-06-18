{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

git-core-ppa:
  pkgrepo.managed:
    - ppa: git-core/ppa

{% endif %} 
