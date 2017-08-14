include:
  - kernel
  - cgroup
  - .ppa

lxd:
  pkg.installed:
    - pkgs:
      - lxc
      - lxd
      - lxd-tools
      - bridge-utils
    - require:
      - sls: cgroup
      - sls: .ppa
