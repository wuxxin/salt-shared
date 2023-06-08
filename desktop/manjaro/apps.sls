{% from 'aur/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}

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

{{ pacman_repo_key("librewolf", "031F7104E932F7BD7416E7F6D2845E1305D6E801", 
    "c7ddd1013c324391d8a5d4151a29df0f4b2c7553e68d42dedda49748a57b293c", user=user) }}

browser:
  pkg.installed:
    - pkgs:
      # disable firefox because we use librewolf as replacement 
      # - firefox
      # chromium - open source version of google-chrome web browser
      - chromium
      # qutebrowser - keyboard-driven, vim-like browser based on PyQt5
      - qutebrowser
      - python-adblock
      - pdfjs
{% load_yaml as pkgs %}
      # librewolf - Community-maintained fork of Firefox, focused on privacy, security and freedom
      - librewolf-bin
{% endload %}
{{ aur_install("browser-aur", pkgs,
    require=["test: trusted-repo-librewolf", "pkg: browser", "pkg: password", "test: password-aur"]) }}

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
{{ pipx_install('yt-dlp', user=user) }}

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
      - highlight


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
      - chromium-keepassxc-browser
      - git-credential-keepassxc
{% endload %}
{{ aur_install("password-aur", pkgs, require="pkg: password") }}

picture:
  pkg.installed:
    - pkgs:
      - darktable
      - digikam
      - hugin
      - qt5-imageformats
      # nautilus-image-converter - extension to rotate/resize image files
      - nautilus-image-converter
      # imv - Image viewer for Wayland and X11
      - imv

# ### picture-pipx
# lama-cleaner - Image inpainting tool powered by SOTA AI Model
#    Remove any unwanted object, defect, people or erase and replace any thing on your pictures.
{{ pipx_install('lama-cleaner', user=user, pipx_opts='--system-site-packages') }}
# ImaginAIry - AI imagined images. Pythonic generation of stable diffusion images.
{{ pipx_install('ImaginAIry', user=user, pipx_opts='--system-site-packages') }}

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

# speech-to-text engine
{% load_yaml as pkgs %}
      - deepspeech-bin
      - deepspeech-models
{% endload %}
{{ aur_install("speech-to-text-aur", pkgs) }}

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
