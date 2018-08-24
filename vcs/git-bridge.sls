include:
  - vcs

git-remote-hg:
  pkg.installed:
    - require:
      - sls: vcs

git-remote-bzr:
  pkg.installed:
    - require:
      - sls: vcs

git-svn:
  pkg.installed:
    - require:
      - sls: vcs
