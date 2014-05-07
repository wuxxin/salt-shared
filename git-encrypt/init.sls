include:
  - git
  - npm
  - openssl

git-encrypt:
  npm.installed:
    - require:
      - pkg: npm
      - pkg: git
      - pkg: openssl
