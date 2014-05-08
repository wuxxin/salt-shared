nodejs:
  pkg.installed:
    - require:
      - pkgrepo: ppa-nodejs


npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


