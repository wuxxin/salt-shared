{% from "lxd/defaults.jinja" import settings with context %}

include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - kernel.cgroup
{% if grains['osrelease_info'][0]|int <= 18 %}
  - ubuntu.backports
{% endif %}

{#
{% if salt['pillar.get']('desktop:development:enabled', false) %}

{% from "network/lib.sls" import net_reverse_short with context %}
{%- set ipnet = settings.networks[0].config['ipv4.address'] %}
{%- set ipaddr = salt['extip.net_interface_addr'](ipnet) %}
{%- set ipmask = salt['extip.cidr_from_net'](ipnet) %}
{%- set interface = {'ipaddr': ipaddr, 'netmask': ipmask} %}

/etc/NetworkManager/dnsmasq.d/lxd:
  file.managed:
    - contents: |
        server=/lxd/{{ ipaddr }}
        server=/{{ net_reverse_short(interface) }}/{{ ipaddr }}
{% endif %}
#}

{# modify kernel vars for production setup of lxd_ http://lxd.readthedocs.io/en/latest/production-setup/ #}

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

{# This is the maximum number of keys a non-root user can use, should be higher than the number of containers #}
kernel.keys.maxkeys:
  sysctl.present:
    - value: 2000 {# 200 #}
{%- endif %}

lxd_prerequisites:
  pkg.installed:
    - pkgs:
      - lvm2
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
      - criu

lxd:
  file.managed:
    - name: /etc/lxd.yaml
    - contents: |
{{ settings|yaml(false)|indent(8,True) }}
  pkg.installed:
    - pkgs:
      - lxd
      - lxd-client
      - lxd-tools
      - lxc-utils
{% if grains['osrelease_info'][0]|int <= 18 %}
    - fromrepo: {{ grains['lsb_distrib_codename'] }}-backports
    - require:
      - sls: ubuntu.backports
{% endif %}
  service.running:
    - enable: True
    - require:
      - pkg: lxd_prerequisites
      - pkg: lxd
      - sls: kernel.cgroup
  cmd.run:
    - name: lxd init --preseed < /etc/lxd.yaml
    - onchanges:
      - file: lxd
    - require:
      - service: lxd
