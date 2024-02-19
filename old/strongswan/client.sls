include:
  - .init

network-manager-strongswan:
  pkg.installed:
    - require:
      - pkg: strongswan
