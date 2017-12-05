include:
  - appliance.base
  - appliance.extra
  - appliance.scripts
  - appliance.systemd
  - appliance.update
  - appliance.backup
  - appliance.metric

appliance_nop:
  test:
    - nop
    - require:
      - sls: appliance.base
      - sls: appliance.extra
      - sls: appliance.scripts
      - sls: appliance.systemd
      - sls: appliance.update
      - sls: appliance.backup
      - sls: appliance.metric
