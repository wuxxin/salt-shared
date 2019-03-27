{% if grains['os'] == 'Ubuntu' %}
  {% if grains['osrelease_info'][0]|int <= 17 and 
    grains['osrelease'] != '17.10' %}
  {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("pulseaudio-dlna_ppa", "qos/pulseaudio-dlna",
  require_in= "pkg: audio-packages") }}
  {% endif %}
{% endif %}
  
audio-packages:
  pkg.installed:
    - pkgs:
      - paprefs
      - pavucontrol
      - pavumeter
      - sox
      - libsox-fmt-pulse
      - lame
      {# from ppa up to zesty #}
      - pulseaudio-dlna

audio-player:
  pkg.installed:
    - pkgs:
      - rhythmbox

audio-editor:
  pkg.installed:
    - pkgs:
      - audacity
