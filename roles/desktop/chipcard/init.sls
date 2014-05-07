include:
  - java.browser

pcscd-prereq:
  pkg.installed:
    - pkgs:
      - pcsc-tools
      - libccid
      - fxcyberjack
      - libifd-cyberjack6

pcscd:
  pkg.installed:
    - require:
      - pkg: pcscd-prereq




