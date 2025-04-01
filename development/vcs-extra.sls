include:
  - development.git

mercurial:
  pkg:
    - installed

subversion:
  pkg:
    - installed

bzr:
  pkg:
    - installed

git-bridge:
  pkg.installed:
    - pkgs:
      - git-remote-hg
      - git-remote-bzr
      - git-svn
    - require:
      - sls: development.git
      - pkg: mercurial
      - pkg: bzr
      - pkg: subversion
