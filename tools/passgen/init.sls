include:
  - python

passgen-common-packages:
  pkg.installed:
    - name: python{{ '3' if grains['os_family']|lower == 'debian' }}-bitstring
    - require:
      - sls: python

/usr/local/bin/passgen.py:
  file.managed:
    - source: salt://tools/passgen/passgen.py
    - mode: "0755"
