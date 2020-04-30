include:
  - vcs.git

vcs_nop_req:
  test:
    - nop
    - require:
      - sls: vcs.git
