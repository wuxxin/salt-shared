include:
  - containers.podman

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

# snapshot from: https://raw.githubusercontent.com/mviereck/x11docker/v6.8.0/x11docker
x11docker:
  file.managed:
    - source: salt://containers/desktop/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: x11docker-tools
