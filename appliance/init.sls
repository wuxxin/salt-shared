include:
  - appliance.base
  - appliance.extra
  - appliance.scripts
  - appliance.systemd
  - appliance.update
  - appliance.backup
  - appliance.metric

appliance_base_nop:
  test:
    - nop
    - require:
      - sls: appliance.base
      
appliance_nop:
  test:
    - nop
    - require:
      - test: appliance_base_nop
      - sls: appliance.extra
      - sls: appliance.scripts
      - sls: appliance.systemd
      - sls: appliance.update
      - sls: appliance.backup
      - sls: appliance.metric
