include:
  - appliance.base

/app/etc/hooks/appliance-prepare/start/00_storage.sh:
  file.managed:
    - source: salt://appliance/storage/appliance-prepare-start-storage.sh
    - mode: "0755"
    - makedirs: true
    - require:
      - sls: appliance.base