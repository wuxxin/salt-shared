smartmontools:
  pkg.installed:
    - pkgs:
      - smartmontools
      - nvme-cli
      - hdparm
  service.running:
    - enable: true
    - require:
      - pkg: smartmontools
