include:
  - .ppa

asciinema:
  pkg.installed:
    - pkgs:
      - asciinema
    - require:
      - cmd: asciinema-ppa
