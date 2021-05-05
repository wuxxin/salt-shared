include:
  - desktop.audio.framework

video-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-alsa
      - gstreamer1.0-pulseaudio
      - gstreamer1.0-pipewire
      - gstreamer1.0-rtsp
      - gstreamer1.0-omx-generic
      - gstreamer1.0-vaapi
      - gstreamer1.0-gl
      - gstreamer1.0-gtk3
      - gstreamer1.0-x
      - gstreamer1.0-libav
      - gstreamer1.0-opencv
      - gstreamer1.0-packagekit
      - gstreamer1.0-plugins-base
      - gstreamer1.0-plugins-base-apps
      - gstreamer1.0-plugins-good
      - gstreamer1.0-plugins-bad
      - gstreamer1.0-plugins-ugly
      - gstreamer1.0-plugins-rtp
      - vainfo
      - lame
      - ffmpeg
      - libavcodec-extra
      - frei0r-plugins
      - gst123

v4l2-tools:
  pkg.installed:
    - pkgs:
      - qv4l2       {# Graphical Qt v4l2 control panel #}
      - uvcdynctrl  {# Command line tool to control v4l2 devices #}
      - v4l-utils   {# video4linux command line utilities #}
      - yavta       {# test Video4Linux2 devices #}
      - fswebcam    {# Tiny and flexible webcam program #}

dvd-css-support:
  pkg.installed:
    - name: libdvd-pkg
    - require:
      - pkg: video-packages
