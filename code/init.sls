include:
  - code.git
  - code.languages
  - code.language-server-protocol

development_nop_req:
  test:
    - nop
    - require:
      - sls: code.git
      - sls: code.languages
      - sls: code.language-server-protocol

