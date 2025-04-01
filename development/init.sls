include:
  - development.git
  - development.languages
  - python.dev

development_nop_req:
  test:
    - nop
    - require:
      - sls: development.git
      - sls: development.languages

