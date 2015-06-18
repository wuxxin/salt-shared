{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
getdeb_ppa:
  pkgrepo.managed:
    - name: deb http://archive.getdeb.net/ubuntu {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }}-getdeb apps
    - file: /etc/apt/sources.list.d/getdeb.list
    - key_url: http://archive.getdeb.net/getdeb-archive.key
{% endif %}

