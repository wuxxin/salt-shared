xpra:
  pkg:
    - installed

# snapshot (2020/10/01) from: https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker
x11docker:
  file.managed:
    - source: salt://containers/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: xpra
