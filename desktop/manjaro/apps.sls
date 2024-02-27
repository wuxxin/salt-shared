{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}
include:
  - python

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
      # tenacity - An easy-to-use multi-track audio editor and recorder, forked from Audacity
      - tenacity

audio-workstation:
  pkg.installed:
    - pkgs:
      - ardour
      - new-session-manager

{{ pacman_repo_key("librewolf", "031F7104E932F7BD7416E7F6D2845E1305D6E801", 
    "732945040a8bc121f75bbac65059eca52880f9f6cb7c65ef91f63c2f0f48a4ac", user=user) }}

{{ pacman_repo_key("librewolf-bin", "662E3CDD6FE329002D0CA5BB40339DD82B12EF16", 
    "25216ea95a354481503e2596ec9ea7b72006e08d3e3bbf6f932dd3ffb096bd32", user=user) }}

browser:
  pkg.installed:
    - pkgs:
      # disable firefox because we use librewolf as replacement 
      # - firefox
      # chromium - open source version of google-chrome web browser
      - chromium
      - pdfjs
{% load_yaml as pkgs %}
      # librewolf - Community-maintained fork of Firefox, focused on privacy, security and freedom
      - librewolf-bin
{% endload %}
{{ aur_install("browser-aur", pkgs,
    require=["test: trusted-repo-librewolf", "test: trusted-repo-librewolf-bin",
        "pkg: browser", "pkg: password", "test: password-aur"]) }}

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
      # syncthing - Open Source Continuous Replication / Cluster Synchronization Thing
      - syncthing
      # rclone - Sync files to and from Google Drive, S3, Swift, Cloudfiles, Dropbox and Google Cloud Storage
      - rclone

file-rename:
  pkg.installed:
    - pkgs:
      # pipe-rename -  list of files as input, opens $EDITOR, then renames those files accordingly
      # eg. find . -regex ".*[][?():'\"\!,&|].*" -print0 | xargs -0 renamer
      - pipe-rename

mail-calendar-contacts:
  pkg.installed:
    - pkgs:
      # Mail,Calendar,Contacts,Notes
      - evolution

{% load_yaml as pkgs %}
      - tabbed-git
      # quickmedia - native client for web services. youtube, soundcloud, a.o.
      - quickmedia-git
{% endload %}
{{ aur_install("media-player-aur", pkgs) }}

music-player:
  pkg.installed:
    - pkgs:
      # lollypop - Music player for GNOME
      - lollypop
      # strawberry - music player aimed at audio enthusiasts and music collectors
      - strawberry

music-tagger:
  pkg.installed:
    - pkgs:
      # picard - Official MusicBrainz tagger
      - picard
      # optional dependencies for picard
      - chromaprint
      # beets - Flexible music library manager and tagger
      - beets
      # optional dependencies for beets
      - python-pylast
      - python-pyacoustid

paper:
  pkg.installed:
    - pkgs:
      # paperwork - personal document manager, scanning, ocr, sorting, searching
      - paperwork

password:
  pkg.installed:
    - pkgs:
      - keepassxc
      - wl-clipboard
{% load_yaml as pkgs %}
      - firefox-extension-keepassxc-browser
      - chromium-extension-keepassxc-browser
      - git-credential-keepassxc
{% endload %}
{{ aur_install("password-aur", pkgs, require="pkg: password") }}

picture:
  pkg.installed:
    - pkgs:
      - darktable
      - digikam
      - hugin
      # nautilus-image-converter - extension to rotate/resize image files
      - nautilus-image-converter
      # imv - Image viewer for Wayland and X11
      - imv

# ### picture-pipx
# lama-cleaner - Image inpainting tool powered by SOTA AI Model
#    Remove any unwanted object, defect, people or erase and replace any thing on your pictures.

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
{{ aur_install("privacy-aur", pkgs, require="pkg: privacy") }}

system-adm:
  pkg.installed:
    - pkgs:
      # systemd-ui - Graphical front-end for systemd
      - systemd-ui
      # systemdgenie - Systemd management utility (kde gui)
      - systemdgenie

# speech-to-text engine

# text-to-speech synthesizer
{% load_yaml as pkgs %}
      - rhvoice
      - rhvoice-voice-evgeniy-eng
{% endload %}
{{ aur_install("speech-synthesizer-aur", pkgs) }}

# themes
{% load_yaml as pkgs %}
      # kali-themes - GTK theme included with Kali Linux
      - kali-themes
{% endload %}
{{ aur_install("themes-aur", pkgs) }}

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
{{ aur_install("video-loopback-aur", pkgs) }}

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
{{ aur_install("video-studio-aur", pkgs) }}
