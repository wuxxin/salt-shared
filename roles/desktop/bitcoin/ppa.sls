{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

bitcoin-ppa:
  pkgrepo.managed:
    - ppa: bitcoin/bitcoin
    - file: /etc/apt/sources.list.d/bitcoin.list

{% endif %} 
