{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


{% if grains['os_family'] == 'Debian' %}

nuxeo_ppa:
  pkgrepo.managed:
    - name: deb http://apt.nuxeo.org/ {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }} fasttracks
    - key_url: salt://nuxeo/nuxeo.key
  cmd.run:
    - name: true
    - require:
      - pkgrepo: nuxeo_ppa

{% endif %} 


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("ffmpeg_ppa", "jon-severinsson/ffmpeg") }}

{% endif %} 
