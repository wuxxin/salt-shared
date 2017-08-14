include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python-dev
      - python3-dev
    - require:
      - sls: python

pip2_install(pudb)
pip3_install(pudb)
