smartmontools:
  service:
    - dead
  pkg:
    - removed
    - require:
      - service: smartmontools
