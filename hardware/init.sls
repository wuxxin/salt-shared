filesystem-tools:
  pkg.installed:
    - pkgs:
      - mdadm
      - lvm2
      - thin-provisioning-tools

storage-tools:
  pkg.installed:
    - pkgs:
      - smartmontools
      - nvme-cli
      - hdparm

temperature-tools:
  pkg.installed:
    - pkgs:
      - lm-sensors
