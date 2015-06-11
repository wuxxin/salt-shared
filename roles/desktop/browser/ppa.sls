{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 


firefox-dev_ppa:
  pkgrepo.managed:
    - ppa: ubuntu-mozilla-daily/firefox-aurora

{% endif %} 
