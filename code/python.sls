include:
  - python.dev

development_python_nop_req:
  test:
    - nop
    - require:
      - sls: python.dev

