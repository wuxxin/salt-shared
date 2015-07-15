{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}

dokku_ppa:
  pkgrepo.managed:
    - name: https://packagecloud.io/dokku/dokku/ubuntu/ trusty main
    - file: /etc/apt/sources.list.d/dokku-trusty.list
    - keyid: EAD883AF
    - keyserver: keys.gnupg.net

{% endif %}
