include:
  - appliance.user
  - .prometheus

/usr/local/share/appliance/prepare-metric.sh:
  file.managed:
    - source: salt://appliance/metric/prepare-metric.sh
    - require:
      - sls: appliance.user
