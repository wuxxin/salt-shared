# entropy gathering daemon, useful for virtual machines and headless server
haveged:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: haveged
