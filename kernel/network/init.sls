include:
  - kernel.modules.network

network-tools:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - ebtables
      - ipset
      - vlan
