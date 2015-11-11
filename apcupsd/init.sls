apcupsd:
  pkg:
    - installed
  service:
    - running
    - enable: true
    - require:
      - pkg: apcupsd
    - watch:
      - file: /etc/default/apcupsd
      - file: /etc/apcupsd/apcupsd.conf

/etc/default/apcupsd:
  file.replace:
    - pattern: "^.*ISCONFIGURED=.*"
    - repl: ISCONFIGURED=yes
    - backup: false
    - require:
      - pkg: apcupsd

/etc/apcupsd/apcupsd.conf:
  file.replace:
    - pattern: "^.*DEVICE /dev/ttyS0"
    - repl: DEVICE
    - backup: false
    - require:
      - pkg: apcupsd
