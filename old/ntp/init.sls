ntp:
  pkg:
    - installed

ntpd:
  service.running:
    - name: ntp
    - enable: True
    - require:
      - pkg: ntp

