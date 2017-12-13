include:
  - desktop.atom.ppa
  - desktop.code
  - desktop.spellcheck

atom:
  pkg.latest:
    - require:
      - sls: desktop.atom.ppa
      - sls: desktop.code
      - sls: desktop.spellcheck
