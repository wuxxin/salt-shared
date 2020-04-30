include:
  - vcs.git
  - openssl

git-crypt:
  pkg.installed:
    - require:
      - pkg: git
      - pkg: openssl
