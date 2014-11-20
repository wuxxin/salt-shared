haveged:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: haveged
