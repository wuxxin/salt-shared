include:
  - vcs.git

git-crypt:
  pkg.installed:
    - pkgs:
      - git-crypt
      - openssl
    - require:
      - pkg: git
