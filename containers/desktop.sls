include:
  - containers

x11docker-tools:
  pkg.installed:
    - pkgs:
      - xinit
      - xauth
      - xclip
      - x11-utils
      - x11-xkb-utils
      - x11-xserver-utils
      - xdg-utils
      - xdotool
      - xpra
      - xserver-xephyr
      - weston
      - xwayland

x11docker-gpu-tools:
  pkg.installed:
    - pkgs:
      - mesa-utils
      - mesa-utils-extra
      - libxv1
      - va-driver-all

x11docker-dbus-tools:
  pkg.installed:
    - pkgs:
      - dbus-x11

# snapshot (6.9.1-beta-1) at 038af50b3389ceaecf5916b29f3bc21ae5c613de
# https://github.com/mviereck/x11docker
x11docker:
  file.managed:
    - source: salt://containers/tools/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: x11docker-tools
      - pkg: x11docker-gpu-tools
      - pkg: x11docker-dbus-tools
