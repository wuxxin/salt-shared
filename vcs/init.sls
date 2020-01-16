include:
  - vcs.git
  - vcs.git-crypt
  - vcs.mercurial
  - vcs.subversion
  - vcs.bzr
  - vcs.git-bridge

vcs_nop_req:
  test:
    - nop
    - require:
      - sls: vcs.git
      - sls: vcs.mercurial
      - sls: vcs.subversion
      - sls: vcs.bzr
      - sls: vcs.git-bridge
