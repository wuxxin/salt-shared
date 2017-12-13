include:
  - .ppa

sonic-pi:
  pkg.installed:
    - pkgs:
      - sonic-pi
    - require:
      - cmd: sonic-pi-ppa
