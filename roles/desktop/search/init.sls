include:
  - .ppa

recoll:
  pkg.installed:
    - require:
      - pkgrepo: recoll_ppa
