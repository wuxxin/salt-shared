{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

manjaro-pipewire:
  pkg.installed:
    - pkgs:
      - manjaro-pipewire
      - pipewire-jack
      - pipewire-v4l2
      - pipewire-x11-bell

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

manjaro-desktop:
  pkg.installed:
    - pkgs:
      - manjaro-gstreamer
      - manjaro-printer

manjaro-qt6:
  pkg.installed:
    - pkgs:
      - qt6-base
      - qt6-wayland
      - qt6-multimedia-gstreamer

# enable cups
{% for s in ['service', 'socket', 'path'] %}
cups.{{ s }}:
  service.enabled:
    - require:
      - pkg: manjaro-desktop
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
