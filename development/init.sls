include:
  - development.git
  - development.languages

development_nop_req:
  test:
    - nop
    - require:
      - sls: development.git
      - sls: development.languages

