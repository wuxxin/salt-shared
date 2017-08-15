{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

  {% if grains['osmajorrelease']|int <= 17 and 
    grains['osrelease'] != '17.10' %}

  {% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("pulseaudio-dlna_ppa", "qos/pulseaudio-dlna") }}

  {% endif %}
{% endif %}

audio_nop:
  test:
    - nop
