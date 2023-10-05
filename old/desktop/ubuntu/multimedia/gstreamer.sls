include:
  - desktop.ubuntu.multimedia.pipewire
  - python

gstreamer-packages:
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
      - gstreamer1.0-tools
      - vainfo
      - ffmpeg
      - libavcodec-extra
      - frei0r-plugins
      - gst123

python-gstreamer-packages:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-gst-1.0
      - gir1.2-gstreamer-1.0
      - gir1.2-gst-plugins-base-1.0
