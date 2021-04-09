include:
  - containers

xpra:
  pkg:
    - installed

# snapshot from: https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker
x11docker:
  file.managed:
    - source: salt://containers/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: xpra
