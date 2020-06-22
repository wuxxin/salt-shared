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

{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}
{# This denies container access to the messages in the kernel ring buffer. Please note that this also will deny access to non-root users on the host system. #}
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1 {# 0 #}
    - require_in:
      - pkg: lxc

{# This is the maximum number of keys a non-root user can use, should be higher than the number of containers #}
kernel.keys.maxkeys:
  sysctl.present:
    - value: 2000 {# 200 #}
    - require_in:
      - pkg: lxc

{# allow normal users to run unprivileged containers #}
kernel.unprivileged_userns_clone:
  sysctl.present:
    - value: 1 {# 0 #}
    - require_in:
      - pkg: lxc
{%- endif %}

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
