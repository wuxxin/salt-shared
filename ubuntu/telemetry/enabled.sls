apport:
  pkg:
    - installed
  service.running:
    - enable: true
    - unmask: true
    - require:
      - pkg: apport

whoopsie:
  pkg:
    - installed
  service.present:
    - enable: true
    - unmask: true
    - require:
      - pkg: whoopsie
