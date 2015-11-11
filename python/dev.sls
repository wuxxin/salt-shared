include:
  - python

python-dev:
  pkg.installed:
    - pkgs:
      - python-dev
    - require:
      - sls: python
