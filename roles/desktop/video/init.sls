include:
  - .ppa

video-packages:
  pkg.installed:
    - pkgs:
      - lame
      - vlc
      - vlc-nox
      - mplayer2
      - smplayer
      - libav-tools
      - libavcodec-extra
      - libdvdread4
      - smtube
      - ffmpeg
      - webcamstudio
      - v4l2loopback-dkms
      - webcamstudio-dkms
      - obs-studio
    - require:
      - cmd: rvm_smplayer_ppa
      - cmd: webcamstudio_ppa
      - cmd: ffmpeg_ppa
      - cmd: obs-studio_ppa

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
install-css:
  {% if grains['lsb_distrib_codename'] == 'trusty' %}
  cmd.run:
    - name: /usr/share/doc/libdvdread4/install-css.sh
    - unless: dpkg-query -s libdvdcss2
    - require:
      - pkg: video-packages
  {% else %}
  pkg.installed:
    - name: libdvd-pkg
    - require:
      - pkg: video-packages
  {% endif %}
{% endif %}


x256-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-libde265
      - vlc-plugin-libde265
    - require:
      - cmd: x265-ppa
