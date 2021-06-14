include:
  - containers

x11docker-tools:
  pkg.installed:
    - pkgs:
      - xpra
      - xserver-xephyr
      - xinit
      - xauth
      - xclip
      - x11-xserver-utils
      - x11-utils
      - weston
      - xwayland
      - xdotool

# snapshot (6.9.1-beta-1) at 038af50b3389ceaecf5916b29f3bc21ae5c613de
# https://github.com/mviereck/x11docker
x11docker:
  file.managed:
    - source: salt://containers/tools/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: x11docker-tools
