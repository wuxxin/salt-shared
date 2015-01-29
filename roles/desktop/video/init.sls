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

install-css:
  cmd.run:
    - name: /usr/share/doc/libdvdread4/install-css.sh
    - require:
      - pkg: video-packages

x256-packages:
  pkg.installed:
    - pkgs:
      - gstreamer1.0-libde265
      - vlc-plugin-libde265
    - require:
      - pkgrepo: x265-ppa
