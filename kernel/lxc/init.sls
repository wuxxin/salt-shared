{% from "kernel.lxc/defaults.jinja" import settings with context %}

{# modify kernel for production http://lxd.readthedocs.io/en/latest/production-setup/ #}
include:
  - kernel
  - kernel.modules
  - kernel.sysctl
  - kernel.limits
  - kernel.limits.memlock
  - kernel.cgroup
  - systemd.cgroup-accounting
  - kernel.network

/etc/default/lxc:
  file.managed:
    - source: salt://lxc/default-lxc

/etc/default/lxc-net:
  file.managed:
    - source: salt://lxc/default-lxc-net

lxc:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - uidmap
      - lxc-utils
      - lxc-templates
    - require:
      - sls: kernel.modules
      - sls: kernel.sysctl
      - sls: kernel.limits
      - sls: kernel.limits.memlock
      - sls: kernel.cgroup
      - sls: systemd.cgroup-accounting
      - sls: kernel.network
