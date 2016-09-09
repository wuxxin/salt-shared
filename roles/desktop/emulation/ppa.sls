{% if grains['lsb_distrib_codename'] == 'trusty' %}
include:
  - repo.ubuntu

getdeb_ppa:
  pkgrepo.managed:
    - name: deb http://archive.getdeb.net/ubuntu {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }}-getdeb apps
    - file: /etc/apt/sources.list.d/getdeb.list
    - key_url: http://archive.getdeb.net/getdeb-archive.key

{% endif %}
