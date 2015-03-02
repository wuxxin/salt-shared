include:
  - .ppa

aptly:
  pkg.installed:
    - require:
      - pkgrepo: aptly_ppa
