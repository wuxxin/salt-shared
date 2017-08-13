include:
  - code
  - .ppa
  - .spellcheck

atom:
  pkg.latest:
    - require:
      - cmd: webupd8team_atom
      - sls: .spellcheck
