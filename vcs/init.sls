include:
  - vcs.git
  - vcs.mercurial
  - vcs.subversion
  - vcs.bzr

vcs_nop:
  test:
    - nop
    - require:
      - sls: vcs.git
      - sls: vcs.mercurial
      - sls: vcs.subversion
      - sls: vcs.bzr
