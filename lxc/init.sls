{% from "lxc/defaults.jinja" import settings with context %}

{# modify kernel for production http://lxd.readthedocs.io/en/latest/production-setup/ #}
include:
  - kernel.server

{#
Domain Type  Item    Value     Default Description
*      soft  memlock unlimited unset   maximum locked-in-memory address space (KB)
*      hard  memlock unlimited unset   maximum locked-in-memory address space (KB)
#}
/etc/security/limits.d/memlock.conf:
  file.managed:
    - contents: |
        *         soft    memlock   unlimited
        *         hard    memlock   unlimited

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
      - bridge-utils
      - ebtables
      - uidmap
      - lxc-utils
      - lxc-templates
    - require:
      - file: /etc/security/limits.d/memlock.conf
      - sls: kernel.server
