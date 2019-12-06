{% from "ubuntu/init.sls" import apt_add_repository %}
  
{% if grains['lsb_distrib_codename'] == 'trusty' %}
{# ffmpeg needs ppa for trusty #}
{{ apt_add_repository("ffmpeg_ppa", "kirillshkrogalev/ffmpeg-next", require_in="pkg: video-packages") }}
{% endif %}
  
video-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-pulseaudio
      - gstreamer1.0-alsa
      - gstreamer1.0-plugins-base
      - gstreamer1.0-plugins-good
      - gstreamer1.0-plugins-bad
      - gstreamer1.0-plugins-ugly
      - gstreamer1.0-libav
      - gstreamer1.0-vaapi
      - vainfo
      - lame
      - ffmpeg
      - libavcodec-extra
      - libdvdread4
      - frei0r-plugins
      - v4l2loopback-dkms
      - gst123
{# gstreamer1.0-rtsp gstreamer1.0-plugins-rtp gstreamer1.0-espeak gstreamer1.0-gtk3 gstreamer1.0-pipewire gstreamer1.0-opencv baresip-gstreamer #}

{% if grains['lsb_distrib_codename'] == 'trusty' %}
{{ apt_add_repository("x265-ppa", "strukturag/libde265", require_in= "pkg: x256-packages") }}
x256-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-libde265
      - vlc-plugin-libde265
{% endif %}

v4l2-tools:
  pkg.installed:
    - pkgs:
      - qv4l2       {# Graphical Qt v4l2 control panel #}
      - uvcdynctrl  {# Command line tool to control v4l2 devices #}
      - v4l-utils   {# video4linux command line utilities #}
      - yavta       {# test Video4Linux2 devices #}
      - fswebcam    {# Tiny and flexible webcam program #}

{% if grains['lsb_distrib_codename'] == 'trusty' %}
dvd-css-support:
  cmd.run:
    - name: /usr/share/doc/libdvdread4/install-css.sh
    - unless: dpkg-query -s libdvdcss2
    - require:
      - pkg: video-packages
{% else %}
dvd-css-support:
  pkg.installed:
    - name: libdvd-pkg
    - require:
      - pkg: video-packages
{% endif %}

video-creation-conversion:
  pkg.installed:
    - pkgs:
      - mkvtoolnix-gui
      - handbrake