include:
  - git
  - mercurial
  - bzr

golang:
  pkg.installed:
    - require:
      - pkg: git
      - pkg: mercurial
      - pkg: bzr
