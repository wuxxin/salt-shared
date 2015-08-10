python:
  pkg.installed:
    - pkgs:
      - python
      - python-pip
      - python-virtualenv

pudb:
  pip.installed:
    - require:
      - pkg: python
