{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'code/python/lib.sls' import pipx_install, pipx_inject %}

include:
  - code.python

audio-pipewire:
  pkg.installed:
    - pkgs:
      # easyeffects - Audio Effects for Pipewire applications
      - easyeffects
      # helvum - patchbay for pipewire, inspired by the JACK tool catia
      - helvum
      # coppwr - Low level PipeWire control GUI
      # - coppwr
{% load_yaml as pkgs %}
      # Pipewire volume control for GNOME
      - pwvucontrol
{% endload %}
{{ aur_install("audio-pipewire-aur", pkgs) }}


audio-converter:
  pkg.installed:
    - pkgs:
      - sox
      - soundconverter
      # whipper - Python CD-DA ripper preferring accuracy over speed
      - whipper

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

cad:
  pkg.installed:
    - pkgs:
      # freecad - Feature based parametric 3D CAD modeler
      - freecad
      # openscad - programmers solid 3D CAD modeller
      - openscad

chat:
  pkg.installed:
    - pkgs:
      - element-desktop
      - signal-desktop
      - telegram-desktop

download:
  pkg.installed:
    - pkgs:
      # Torrent Download Gui
      - transmission-gtk
      # yt-dlp - youtube-dl fork with additional features and fixes
      - yt-dlp

fediverse:
  pkg.installed:
    - pkgs:
      # tokodon - Mastodon client for Plasma
      - tokodon
      # tuba - Browse the Fediverse
      - tuba

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

gnome-extensions:
  pkg.installed:
    - pkgs:
      # gnome-browser-connector - Native browser connector for integration with extensions.gnome.org
      - gnome-browser-connector

mail-calendar-contacts:
  pkg.installed:
    - pkgs:
      # Mail,Calendar,Contacts,Notes
      - evolution

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
      # tesseract - tesseract OCR Engine
      - tesseract
      - tesseract-data-eng
      - tesseract-data-deu

password:
  pkg.installed:
    - pkgs:
      - keepassxc
      - wl-clipboard
{% load_yaml as pkgs %}
      - firefox-extension-keepassxc-browser
      - chromium-extension-keepassxc-browser
      - librewolf-extension-keepassxc-browser
      - git-credential-keepassxc
{% endload %}
{{ aur_install("password-aur", pkgs, require="pkg: password") }}

pdf-tools:
  pkg.installed:
    - pkgs:
      # evince - Document viewer (PDF, PostScript, XPS, djvu, dvi, tiff, cbr, cbz, cb7, cbt)
      - evince
      # mupdf - Lightweight PDF and XPS viewer
      - mupdf
      - mupdf-tools
{% load_yaml as pkgs %}
      # sioyek - PDF viewer with a focus on textbooks and research papers
      - sioyek
{% endload %}
{{ aur_install("pdf-viewer-aur", pkgs) }}

picture:
  pkg.installed:
    - pkgs:
      - darktable
      - digikam
      # nautilus-image-converter - extension to rotate/resize image files
      - nautilus-image-converter
      # loupe - simple image viewer for GNOME
      - loupe
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
{% load_yaml as pkgs %}
      - vlc-plugin-pipewire
{% endload %}
{{ aur_install("video-player-aur", pkgs) }}

video-studio:
  pkg.installed:
    - pkgs:
      - obs-studio
      - sndio
      # snapshot - Take pictures and videos
      - snapshot
{% load_yaml as pkgs %}
      - webcamoid
      - obs-pipewire-audio-capture
{% endload %}
{{ aur_install("video-studio-aur", pkgs) }}
