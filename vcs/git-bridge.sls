include:
  - vcs.init

git-remote-hg:
  pkg.installed:
    - require:
      - sls: vcs.init

git-remote-bzr:
  pkg.installed:
    - require:
      - sls: vcs.init

git-svn:
  pkg.installed:
    - require:
      - sls: vcs.init
