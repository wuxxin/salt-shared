{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 


firefox-dev_ppa:
  pkgrepo.managed:
    - ppa: ubuntu-mozilla-daily/firefox-aurora
    - file: /etc/apt/sources.list.d/ubuntu-mozilla-daily.list

{% endif %} 
