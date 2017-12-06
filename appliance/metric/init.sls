include:
  - appliance.base
  - .prometheus

/usr/local/share/appliance/metric.functions.sh:
  file.managed:
    - source: salt://appliance/metric/metric.functions.sh
    - require:
      - sls: appliance.base

/app/etc/hooks/prepare-appliance/start/metric.sh:
  file.managed:
    - source: salt://appliance/backup/prepare-appliance-start-metric.sh
    - mode: "0755"
    - require:
      - sls: appliance.base
