{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

  {% if grains['osrelease_info'][0]|int <= 17 and 
    grains['osrelease'] != '17.10' %}

  {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("pulseaudio-dlna_ppa", "qos/pulseaudio-dlna") }}

  {% endif %}
{% endif %}

audio_nop:
  test:
    - nop
