{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

  {% from "repo/ubuntu.sls" import apt_add_repository %}
  {% if grains['lsb_distrib_codename'] == 'trusty' %}
    {{ apt_add_repository("x265-ppa", "strukturag/libde265") }}
    {{ apt_add_repository("ffmpeg_ppa", "kirillshkrogalev/ffmpeg-next") }}
  {% endif %}

  {{ apt_add_repository("rvm_smplayer_ppa", "rvm/smplayer") }}
  {{ apt_add_repository("webcamstudio_ppa", "webcamstudio/webcamstudio-dailybuilds") }}
  {{ apt_add_repository("obsstudio_ppa", "obsproject/obs-studio") }}
{% endif %}
