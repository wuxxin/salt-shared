{# modify kernel for production http://lxd.readthedocs.io/en/latest/production-setup/ #}
include:
  - kernel
  - kernel.sysctl
  - kernel.limits
  - kernel.limits.memlock
  - kernel.network
  - systemd.cgroup

{#
/etc/default/lxc:
  file.managed:
    - source: salt://lxc/default-lxc

/etc/default/lxc-net:
  file.managed:
    - source: salt://lxc/default-lxc-net
#}

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
      - sls: kernel.network
      - sls: systemd.cgroup
