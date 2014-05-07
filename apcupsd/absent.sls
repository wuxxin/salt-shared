apcupsd:
  pkg:
    - absent
  service:
    - dead
    - require:
      - pkg: apcupsd
