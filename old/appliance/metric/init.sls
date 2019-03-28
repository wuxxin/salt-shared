include:
  - appliance.base
  - .prometheus

/usr/local/share/appliance/metric.functions.sh:
  file.managed:
    - source: salt://appliance/metric/metric.functions.sh
    - require:
      - sls: appliance.base

/app/etc/hooks/appliance-prepare/start/metric.sh:
  file.managed:
    - source: salt://appliance/metric/appliance-prepare-start-metric.sh
    - mode: "0755"
    - makedirs: true
    - require:
      - sls: appliance.base
