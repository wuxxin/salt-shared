apcupsd:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: apcupsd
    - watch:
      - file: /etc/default/apcupsd
      - file: /etc/apcupsd/apcupsd.conf

/etc/default/apcupsd:
  file.sed:
    - before: ^ISCONFIGURED=no
    - after: ISCONFIGURED=yes 
    - require:
      - pkg: apcupsd

/etc/apcupsd/apcupsd.conf:
  file.sed:
    - before: ^DEVICE /dev/ttyS0
    - after: DEVICE
    - require:
      - pkg: apcupsd

