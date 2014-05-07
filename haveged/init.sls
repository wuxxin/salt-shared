haveged:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: haveged
