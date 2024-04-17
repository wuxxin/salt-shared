{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

manjaro-pipewire:
  pkg.installed:
    - pkgs:
      - manjaro-pipewire
      - pipewire-jack
      - pipewire-pulse
      - pipewire-v4l2
      - pipewire-roc
      - pipewire-x11-bell
      - lib32-pipewire-jack
      - qemu-audio-pipewire
      - wireplumber

{% load_yaml as pkgs %}
      # wayland-pipewire-idle-inhibit - Inhibit wayland idle when computer is playing sound
      - wayland-pipewire-idle-inhibit
{% endload %}
{{ aur_install("audio-pipewire-aur", pkgs) }}

enable_wayland-pipewire-idle-inhibit:
  file.symlink:
    - name: {{ user_home+ '/.config/systemd/user/graphical-session.target.wants/wayland-pipewire-idle-inhibit.service' }}
    - target: /usr/lib/systemd/user/wayland-pipewire-idle-inhibit.service
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - test: audio-pipewire-aur

# remove traces of pulse audio
manjaro-pulse:
  pkg.removed:
    - pkgs:
      - manjaro-pulse
      - pulseaudio-lirc
      - pulseaudio-jack
      - pulseaudio-equalizer
      - pulseaudio-equalizer-ladspa
      - pulseaudio-rtp
      - pulseaudio-bluetooth
      - pulseaudio-zeroconf
      - pulseaudio

# remove snapd and dependencies
manjaro-snap:
  pkg.removed:
    - pkgs:
      - libpamac-snap-plugin
      - snapd

manjaro-gstreamer:
  pkg.installed:
    - pkgs:
      - manjaro-gstreamer
      - gst-plugin-pipewire

manjaro-qt6:
  pkg.installed:
    - pkgs:
      - qt6-base
      - qt6-wayland
      - qt6-multimedia
      - qt6-multimedia-gstreamer
      - qt6-multimedia-ffmpeg
      - qt6-imageformats
      - qt6-charts
      - qt6-sensors
      - qt6-serialport
      - qt6-svg
      - qt6-tools
      - qt6-webchannel
      - qt6-webengine
      - qt6-websockets
      - qt6-5compat

manjaro-qt5:
  pkg.installed:
    - pkgs:
      - qt5-base
      - qt5-wayland
      - qt5-multimedia
      - qt5ct

# cups
manjaro-printer:
  pkg.installed:
    - pkgs:
      - manjaro-printer

{% for s in ['service', 'socket', 'path'] %}
cups.{{ s }}:
  service.disabled:
    - require:
      - pkg: manjaro-printer
{% endfor %}

# make sure wayland as gui platform is used
{{ user_home }}/.config/environment.d/envvars.conf:
  file.managed:
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
    - contents: |
        # QT5/6 (packages qt5-wayland,qt6-wayland)
        QT_QPA_PLATFORM=wayland
        # To run a SDL2 application on Wayland
        SDL_VIDEODRIVER=wayland
        # Run Firefox on Wayland
        MOZ_ENABLE_WAYLAND=1
