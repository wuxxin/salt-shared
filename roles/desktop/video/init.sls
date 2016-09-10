{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

include:
  - .ppa

video-packages:
  pkg.installed:
    - pkgs:
      - lame
      - vlc
      - vlc-nox
      - mplayer2
      - libav-tools
      - libavcodec-extra
      - libdvdread4
      - smplayer
      - smtube
      - smplayer-themes
      - smplayer-skins
      - youtube-dl
      - webcamstudio
      - v4l2loopback-dkms
      - webcamstudio-dkms
      - obs-studio
      - ffmpeg
    - require:
      - cmd: rvm_smplayer_ppa
      - cmd: webcamstudio_ppa
      - cmd: obsstudio_ppa
  {% if grains['lsb_distrib_codename'] == 'trusty' %}
      - cmd: ffmpeg_ppa
  {% endif %}

  {% if grains['lsb_distrib_codename'] == 'trusty' %}
install-css:
  cmd.run:
    - name: /usr/share/doc/libdvdread4/install-css.sh
    - unless: dpkg-query -s libdvdcss2
    - require:
      - pkg: video-packages
  {% else %}
install-css:
  pkg.installed:
    - name: libdvd-pkg
    - require:
      - pkg: video-packages
  {% endif %}

  {% if grains['lsb_distrib_codename'] == 'trusty' %}
x256-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-libde265
      - vlc-plugin-libde265
    - require:
      - cmd: x265-ppa
  {% endif %}
{% endif %}
