{% from "lxd/defaults.jinja" import settings with context %}

include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - kernel.cgroup
  - ubuntu.backports

{% if salt['pillar.get']('desktop:development:enabled', false) %}

{% from "network/lib.sls" import net_reverse_short with context %}
{%- set ipnet = settings.networks[0].config.ipv4.address %}
{%- set ipaddr = salt['extip.net_interface_addr'](ipnet) %}
{%- set ipmask = salt['extip.cidr_from_net'](ipnet) %}
{%- set interface = {'ipaddr': ipaddr, 'netmask': ipmask} %}

/etc/NetworkManager/dnsmasq.d/lxd:
  file.managed:
    - contents: |
        server=/lxd/{{ ipaddr }}
        server=/{{ net_reverse_short(interface) }}/{{ ipaddr }}
{% endif %}

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
  service.running:
    - enable: True
    - require:
      - pkg: lxd
      - sls: kernel.cgroup
      - sls: ubuntu.backports
  module.run:
    - name: cmd.run
    - m_name: lxd init --preseed
    - require:
      - service: lxd
    - stdin: |
{{ settings|yaml(false)|indent(10,True) }}


