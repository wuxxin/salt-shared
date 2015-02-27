{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os_family'] == 'Debian' %}

nuxeo-ppa:
  pkgrepo.managed:
    - name: deb http://apt.nuxeo.org/ {{ grains['lsb_distrib_codename'] }} fasttracks
    - key_url: salt://nuxeo/nuxeo.key

{% endif %} 
