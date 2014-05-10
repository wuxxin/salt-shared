include:
  - .ppa

tlp:
  pkg.installed:
    - pkgs:
      - tlp
      - tlp-rdw
    - require:
      - pkgrepo: tlp-ppa

psensor:
  pkg:
    - installed
