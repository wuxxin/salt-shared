smartmontools:
  pkg:
    - removed
  service:
    - dead
    - require:
      - pkg: smartmontools
    - watch:
      - file: /etc/default/smartmontools

/etc/default/smartmontools:
  file.comment:
    - regex: start_smartd=yes
    - backup: false
    - require:
      - pkg: smartmontools
