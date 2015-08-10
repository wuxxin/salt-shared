include:
  - .ppa

geary:
  pkg.installed:
    - require:
      - cmd: yorba-ppa


# geary will be an email client; current version is 0.8 and still lot of functions missing
