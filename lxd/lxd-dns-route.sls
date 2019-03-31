
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
