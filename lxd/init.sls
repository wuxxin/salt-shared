include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - cgroup
  - lxd.ppa
{% if grains['osname'] == 'trusty' %}
  {# lxd needs newer (2.0.x) libxc1, trusty has it in backports #}
  - ubuntu.backports
{% endif %}

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
{% if grains['osname'] == 'trusty' %}
      - sls: ubuntu.backports
{% endif %}

{# modify kernel vars for production setup of lxd_ http://lxd.readthedocs.io/en/latest/production-setup/ #}

/etc/security/limits.d/memlock.conf:
  file.managed:
    - contents: |
        *         soft    memlock   unlimited
        *         hard    memlock   unlimited

{# This specifies the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of calling malloc, directly by mmap and mprotect, and also when loading shared libraries. #}
vm.max_map_count:
  sysctl.present:
    - value: 262144 {# 65530 #}

{# This denies container access to the messages in the kernel ring buffer. Please note that this also will deny access to non-root users on the host system. #}
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1 {# 0 #}
