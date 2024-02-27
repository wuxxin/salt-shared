include:
  - hardware.amd.radeon

hardware:
  test:
    - nop
    - require:
      - sls: hardware.amd.radeon
