include:
  - kernel
  - cgroup
  - lxd.ppa

lxd:
  pkg.installed:
    - pkgs:
      - lxc
      - lxd
      - lxd-tools
      - bridge-utils
    - require:
      - sls: cgroup
      - sls: lxd.ppa
