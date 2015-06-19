include:
  - .init

NetworkManager-strongswan:
  pkg.installed:
    - require:
      - pkg: strongswan
      
