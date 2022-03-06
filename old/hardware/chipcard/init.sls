pcscd-prereq:
  pkg.installed:
    - pkgs:
      - pcsc-tools
      - libccid {# all usb smartcard reader #}
      - libifd-cyberjack6

pcscd:
  pkg.installed:
    - require:
      - pkg: pcscd-prereq
