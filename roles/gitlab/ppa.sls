{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

git-core-ppa:
  pkgrepo.managed:
    - ppa: git-core/ppa

{% endif %} 
