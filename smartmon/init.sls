smartmontools:
  pkg:
    - installed
  service.running:
    - enable: true
    - require:
      - pkg: smartmontools
    - watch:
      - file: /etc/default/smartmontools

/etc/default/smartmontools:
  file.uncomment:
    - regex: start_smartd=yes
    - backup: false
    - require:
      - pkg: smartmontools
