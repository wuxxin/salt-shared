{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %} 


{% if grains['os_family'] == 'Debian' %}
nuxeo_ppa:
  pkgrepo.managed:
    - name: deb http://apt.nuxeo.org/ {{ grains['lsb_distrib_codename'] }} fasttracks
    - key_url: salt://nuxeo/nuxeo.key
  cmd.run:
    - name: true
    - require:
      - pkgrepo: nuxeo_ppa
{% endif %} 

{% if grains['os'] == 'Ubuntu' %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("ffmpeg_ppa", "jon-severinsson/ffmpeg") }}

{% endif %} 

nuxeo_nop:
  test:
    - nop
