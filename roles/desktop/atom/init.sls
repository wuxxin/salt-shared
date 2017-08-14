include:
  - roles.desktop.atom.ppa
  - roles.desktop.code
  - roles.desktop.spellcheck

atom:
  pkg.latest:
    - require:
      - sls: roles.desktop.atom.ppa
      - sls: roles.desktop.code
      - sls: roles.desktop.spellcheck
