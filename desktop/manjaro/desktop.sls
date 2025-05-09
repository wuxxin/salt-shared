{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

# audio: use pipewire instead of pulse audio
manjaro-pipewire:
  pkg.installed:
    - pkgs:
      - manjaro-pipewire
      - pipewire-alsa
      - pipewire-jack
      - pipewire-pulse
      - pipewire-v4l2
      - pipewire-roc
      - pipewire-x11-bell
      - pipewire-libcamera
      # wireplumber is a modern pipewire session manager
      - wireplumber
      - sof-firmware
      - lib32-pipewire-jack
      - lib32-pipewire-v4l2
      - qemu-audio-pipewire

# pipewire is configured to be a jack daemon, install jack utils
manjaro-jack-pipewire:
  pkg.installed:
    - pkgs:
      - jack_utils
      - jack_capture
      - jack_delay
      - jack-stdio
      - jack-example-tools
    - require:
      - pkg: manjaro-pipewire

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

# remove snapd (is proprietary)
manjaro-snap:
  pkg.removed:
    - pkgs:
      - snapd

manjaro-gstreamer:
  pkg.installed:
    - pkgs:
      - manjaro-gstreamer
      - gstreamer-vaapi
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

# printing with cups
manjaro-printer:
  pkg.installed:
    - pkgs:
      - manjaro-printer
      - system-config-printer

# configure cups: connect only to socket, do not listen or advertise to the network, do not start webgui
{% set print_config_list= [
  ('Listen localhost:631', '#Listen localhost:631'),
  ('Listen \\\\*:631', '#Listen *:631'),
  ('Listen \\\\[::1\\\\]:631', '#Listen [::1]:631'),
  ('Listen /run/cups/cups.sock', 'Listen /run/cups/cups.sock'),
  ('Browsing', 'Browsing No'),
  ('BrowseLocalProtocols', 'BrowseLocalProtocols none'),
  ('BrowseWebIF', 'BrowseWebIF No'),
  ('WebInterface', 'WebInterface No'),
  ('DefaultShared', 'DefaultShared No'),
  ]
%}

{% for pattern, repl in print_config_list %}
"cups_{{ pattern }}":
  file.replace:
    - name: /etc/cups/cupsd.conf
    - pattern: |
        ^{{ pattern }}.*
    - repl: |
        {{ repl }}
    - append_if_not_found: true
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
