{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

dokku-alt_ppa:
  pkgrepo.managed:
    - name: deb http://dokku-alt.github.io/dokku-alt /
    - file: /etc/apt/sources.list.d/dokku-alt.list
    - keyid: EAD883AF
    - keyserver: keys.gnupg.net

{% endif %} 
