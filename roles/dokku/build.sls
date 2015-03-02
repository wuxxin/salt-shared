{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

dokku-alt_ppa:
  pkgrepo.managed:
    - name: deb http://dokku-alt.github.io/dokku-alt /
    - file: /etc/apt/sources.list.d/dokku-trusty.list
    - keyid: EAD883AF
    - keyserver: keys.gnupg.net

{% endif %} 
