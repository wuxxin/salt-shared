include:
  - python

flatyaml-common-packages:
  pkg.installed:
    - pkgs:
      - python3-yaml
    - require:
      - sls: python

/usr/local/bin/flatyaml.py:
  file.managed:
    - source: salt://tools/flatyaml/flatyaml.py
    - mode: "0755"
