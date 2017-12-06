include:
  - appliance.base

/app/etc/hooks/prepare-appliance/start/00_storage.sh:
  file.managed:
    - source: salt://appliance/backup/prepare-appliance-start-storage.sh
    - mode: "0755"
    - require:
      - sls: appliance.base