{% if grains['os'] == 'Ubuntu' %}

include:
  - desktop.video.ppa

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
      - gstreamer1.0-fluendo-mp3
      - lame
      - libav-tools
      - libavcodec-extra
      - libdvdread4
      - frei0r-plugins
      - v4l2loopback-dkms
      {# ffmpeg needs ppa for trusty #}
      - ffmpeg
      
      - vlc
      - vlc-nox
      - vlc-plugin-vlsub
      - mplayer
      - openshot-qt
      
      {# obs-studio is available in zesty upwards, but newer in ppa #}
      - obs-studio
      
      {# smplayer, smtube, youtube-dl is available in trusty upwards, but newer in ppa #}
      - smplayer
      - smplayer-themes
      - smplayer-skins
      - smtube
      - youtube-dl
      
    - require:
      - sls: desktop.video.ppa

  {% if grains['osrelease_info'][0]|int <= 16 and 
        grains['osrelease'] != '16.10' %}
  {# webcamstudio is available up to xenial and need ppa #}  
webcamstudio:
  pkg.installed:
    - pkgs:
      - webcamstudio
      - webcamstudio-dkms
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
      - sls: desktop.video.ppa
  {% endif %}

{% endif %}
