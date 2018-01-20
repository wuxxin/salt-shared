{% from "lxd/defaults.jinja" import settings with context %}

include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - kernel.cgroup
  - ubuntu.backports

{% if salt['pillar.get']('desktop:development:enabled', false) %}
{% from "network/lib.sls" import net_reverse_short with context %}

/etc/NetworkManager/dnsmasq.d/lxd:
  file.managed:
    - contents: |
        server=/lxd/{{ settings.ipaddr }}
        server=/{{ net_reverse_short(settings) }}/{{ settings.ipaddr }}
{% endif %}

lxd:
  pkg.installed:
    - pkgs:
      - lxc
      - lxd
      - lxd-tools
      - lvm2
      - thin-provisioning-tools
      - criu
      - bridge-utils
    - require:
      - sls: kernel.cgroup
      - sls: ubuntu.backports

{# modify kernel vars for production setup of lxd_ http://lxd.readthedocs.io/en/latest/production-setup/ #}

/etc/security/limits.d/memlock.conf:
  file.managed:
    - contents: |
        *         soft    memlock   unlimited
        *         hard    memlock   unlimited

{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}  

{# This specifies the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of calling malloc, directly by mmap and mprotect, and also when loading shared libraries. #}
vm.max_map_count:
  sysctl.present:
    - value: 262144 {# 65530 #}

{# This denies container access to the messages in the kernel ring buffer. Please note that this also will deny access to non-root users on the host system. #}
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1 {# 0 #}

{%- endif %}
