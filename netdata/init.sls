include:
  - python

netdata:
  pkg.installed:
    - pkgs:
      - fping
      - netdata
      - netdata-plugins-python
    - require:
      - sls: python
