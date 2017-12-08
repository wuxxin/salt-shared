include:
  - appliance.base

/app/etc/hooks/appliance-prepare/start/00_storage.sh:
  file.managed:
    - source: salt://appliance/backup/appliance-prepare-start-storage.sh
    - mode: "0755"
    - require:
      - sls: appliance.base