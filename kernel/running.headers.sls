linux-tools:
  pkg.installed:
    - pkgs:
      - linux-tools-{{ grains['kernelrelease'] }}

linux-headers:
  pkg.installed:
    - pkgs:
      - linux-headers-{{ grains['kernelrelease'] }}
