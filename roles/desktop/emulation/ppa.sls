{% if grains['lsb_distrib_codename'] in ['trusty', 'xenial'] %}
include:
  - repo.ubuntu

getdeb_ppa:
  pkgrepo.managed:
    - name: deb http://archive.getdeb.net/ubuntu {{ grains['lsb_distrib_codename'] }}-getdeb apps
    - file: /etc/apt/sources.list.d/getdeb.list
    - key_url: http://archive.getdeb.net/getdeb-archive.key

{% endif %}
