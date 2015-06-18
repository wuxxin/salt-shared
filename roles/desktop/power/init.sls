include:
  - .ppa

tlp:
  pkg.installed:
    - pkgs:
      - tlp
      - tlp-rdw
    - require:
      - cmd: tlp-ppa

psensor:
  pkg:
    - installed
