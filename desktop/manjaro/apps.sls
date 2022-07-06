{% from 'manjaro/lib.sls' import pamac_install with context %}

3dprinting:
  pkg.installed:
    - pkgs:
      - cura
      - cura-binary-data
      - python-libcharon
      - python-trimesh

audio-effects:
  pkg.installed:
    - pkgs:
      - easyeffects
      - helvum

audio-converter:
  pkg.installed:
    - pkgs:
      - sox
      - soundconverter

audio-editor:
  pkg.installed:
    - pkgs:
      - audacity

audio-workstation:
  pkg.installed:
    - pkgs:
      - ardour
      - new-session-manager

browser:
  pkg.installed:
    - pkgs:
      - firefox
      - chromium

chat:
  pkg.installed:
    - pkgs:
      - element-desktop
      - signal-desktop

code:
  pkg.installed:
    - pkgs:
      - atom
      - ctags

download:
  pkg.installed:
    - pkgs:
      # Torrent Download Gui
      - transmission-gtk
      # yt-dlp - youtube-dl fork with additional features and fixes
      - yt-dlp

mail-calendar-contacts:
  pkg.installed:
    - pkgs:
      # Mail,Calendar,Contacts,Notes
      - evolution
      - highlight

multimedia-player:
  pkg.installed:
    - pkgs:
      # kodi -  software media player and entertainment hub for digital media
      - kodi

music-player:
  pkg.installed:
    - pkgs:
      - lollypop

music-tagger:
  pkg.installed:
    - pkgs:
      - picard

password:
  pkg.installed:
    - pkgs:
      - keepassxc
      - wl-clipboard
{% load_yaml as pkgs %}
      - firefox-extension-keepassxc-browser
      - chromium-keepassxc-browser
{% endload %}
{{ pamac_install("password_aur", pkgs, require="pkg: password") }}

picture:
  pkg.installed:
    - pkgs:
      - darktable
      - digikam
      - hugin
      - qt5-imageformats
      # nautilus-image-converter - extension to rotate/resize image files
      - nautilus-image-converter

pixel-graphic:
  pkg.installed:
    - pkgs:
      - gimp
      - krita

privacy:
  pkg.installed:
    - pkgs:
      - torbrowser-launcher
      # mat2 - Metadata removal tool, supporting a wide range of commonly used file formats
      - mat2
{% load_yaml as pkgs %}
      - metadata-cleaner
{% endload %}
{{ pamac_install("privacy-aur", pkgs, require="pkg: privacy") }}

sync:
  pkg.installed:
    - pkgs:
      - syncthing

vector-graphic:
  pkg.installed:
    - pkgs:
      - inkscape
      - scour

video-converter:
  pkg.installed:
    - pkgs:
      - handbrake

video-editor:
  pkg.installed:
    - pkgs:
      - openshot

video-player:
  pkg.installed:
    - pkgs:
      - vlc

video-loopback:
  pkg.installed:
    - pkgs:
      - v4l2loopback-utils
      - v4l2loopback-dkms

{{ pamac_install("video-loopback-aur", [ "akvcam-dkms" ]) }}
