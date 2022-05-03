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

{% for s in ['service', 'socket', 'path'] %}
cups.{{ s }}:
  service.enabled:
    - require:
      - pkg: manjaro-desktop
{% endfor %}

{#
+ user config for wayland
    + env vars for native wayland support
        + wayland uses systemd user environment variables
        + edit ~/.config/environment.d/envvars.conf
```shell
# QT5/6 (packages qt5-wayland,qt6-wayland)
QT_QPA_PLATFORM=wayland
# To run a SDL2 application on Wayland
SDL_VIDEODRIVER=wayland
# Run Firefox on Wayland
MOZ_ENABLE_WAYLAND=1
```
    + electron based applications
        + To use electron-based applications natively under Wayland,
          create or edit the file ${XDG_CONFIG_HOME}/electron-flags.conf
          to add the following options
```
--enable-features=UseOzonePlatform
--ozone-platform=wayland
```
#}
