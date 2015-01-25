{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

dokku-alt:
  pkgrepo.managed:
    - name: https://dokku-alt.github.io/dokku-alt
    - keyid: EAD883AF!!!
    - keyserver: keys.gnupg.net

{% endif %} 
