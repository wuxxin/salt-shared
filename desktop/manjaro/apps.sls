{% from 'manjaro/lib.sls' import pamac_install with context %}

3d-printing:
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
{% load_yaml as pkgs %}
      - firefox-extension-keepassxc-browser
      - chromium-keepassxc-browser
{% endload %}
{{ pamac_install("browser-aur", pkgs, require="pkg: password") }}

chat:
  pkg.installed:
    - pkgs:
      - element-desktop
      - signal-desktop

download:
  pkg.installed:
    - pkgs:
      # Torrent Download Gui
      - transmission-gtk
      # yt-dlp - youtube-dl fork with additional features and fixes
      - yt-dlp

file-sync:
  pkg.installed:
    - pkgs:
      - syncthing

mail-calendar-contacts:
  pkg.installed:
    - pkgs:
      # Mail,Calendar,Contacts,Notes
      - evolution
      - highlight

media-player:
  pkg.installed:
    - pkgs:
      # kodi -  software media player and entertainment hub for digital media
      - kodi
{% load_yaml as pkgs %}
      - tabbed-git
      # quickmedia - native client for web services. youtube, soundcloud, a.o.
      - quickmedia-git
{% endload %}
{{ pamac_install("media-player-aur", pkgs) }}

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
      - chromium-extension-keepassxc-browser
      - chromium-keepassxc-browser
      - git-credential-keepassxc
{% endload %}
{{ pamac_install("password-aur", pkgs, require="pkg: password") }}

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

# themes
{% load_yaml as pkgs %}
      # kali-themes - GTK theme included with Kali Linux
      - kali-themes
{% endload %}
{{ pamac_install("themes-aur", pkgs) }}

vector-graphic:
  pkg.installed:
    - pkgs:
      - inkscape
      - scour

video-converter:
  pkg.installed:
    - pkgs:
      - handbrake
      - avidemux-qt

video-editor:
  pkg.installed:
    - pkgs:
      - openshot
      - shotcut
      - kdenlive
      - noise-suppression-for-voice

video-loopback:
  pkg.installed:
    - pkgs:
      - v4l2loopback-utils
      - v4l2loopback-dkms
{% load_yaml as pkgs %}
      - akvcam-dkms
{% endload %}
{{ pamac_install("video-loopback-aur", pkgs) }}

video-player:
  pkg.installed:
    - pkgs:
      - vlc

video-studio:
  pkg.installed:
    - pkgs:
      - obs-studio
      - sndio
{% load_yaml as pkgs %}
      - webcamoid
{% endload %}
{{ pamac_install("video-studio-aur", pkgs) }}
