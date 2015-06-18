{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


{% if grains['os_family'] == 'Debian' %}

nuxeo_ppa:
  pkgrepo.managed:
    - name: deb http://apt.nuxeo.org/ {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }} fasttracks
    - key_url: salt://nuxeo/nuxeo.key

{% endif %} 


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

ffmpeg_ppa:
  pkgrepo.managed:
    - ppa: jon-severinsson/ffmpeg

#olena_ppa:
#  pkgrepo.managed:
#    - ppa: olena/ppa

{% endif %} 
