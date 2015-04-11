include:
  - .init

python-dev:
  pkg.installed:
    - pkgs:
      - python-dev
    - require:
      - pkg: python
pudb:
  pip.installed:
    - require:
      - pkg: python
