at:
  pkg:
    - installed
  service.running:
    - name: atd
    - enable: true
    - require:
      - pkg: atd
