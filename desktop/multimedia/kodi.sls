include:
  - desktop.multimedia.gstreamer
  - desktop.multimedia.pipewire

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("kodi_ppa", "team-xbmc/ppa", require_in= "pkg: kodi") }}
{% endif %}

kodi:
  pkg:
    - installed
