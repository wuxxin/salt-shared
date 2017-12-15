include:
  - python

passgen-common-packages:
  pkg.installed:
    - pkgs:
      - python3-bitstring
      - openssl
    - require:
      - sls: python

/usr/local/bin/passgen.py:
  file.managed:
    - source: salt://tools/passgen/passgen.py
    - mode: "0755"
