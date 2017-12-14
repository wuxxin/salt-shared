snapd:
  pkg:
    - installed
  service.running:
    - enable: true
    - unmask: true
    - require:
      - pkg: snapd
