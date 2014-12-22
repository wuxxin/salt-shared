{% set sys_network = salt['pillar.get']('network:system', {}) %}
{% set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{% set routes = salt['pillar.get']('network:routes', {}) %}
{% set groups = salt['pillar.get']('network:groups', {}) %}

{% from "network/lib.sls" import net_list, net_addr, net_short, net_addr_cidr, net_broadcast, net_reverse, net_reverse_short, net_calc with context %}

{% set a=[] %}
{% set b=[] %}
{% set c=[] %}
{% set d=[] %}
{% set e=[] %}
{% set f=[] %}
{% set g=[] %}

{% for n in groups.masquerade %}
{% do a.append(net_addr(interfaces[n])) %}
{% do b.append(net_short(interfaces[n])) %}
{% do c.append(net_addr_cidr(interfaces[n])) %}
{% do d.append(net_broadcast(interfaces[n])) %}
{% do e.append(net_reverse(interfaces[n])) %}
{% do f.append(net_reverse_short(interfaces[n])) %}
{% do g.append(net_calc(interfaces[n], 5)) %}
{% endfor %}


{% load_yaml as defaults %}
cache_serve_to: 
{%- for n in net_list('masquerade', 'net_short')|load_yaml %}
  - "{{ n }}"
{%- endfor %}
cache_follow:
{%- for n in net_list('masquerade', 'net_reverse_short', address_postfix='.in-addr.arpa')|load_yaml %}
  "{{ n }}": "192.168.47.13"
{%- endfor %}
masq:
  - eth0 {{ net_list('masquerade', 'net_addr_cidr')|load_yaml|join(' ') }}
ip_routes:
{%- for n in net_list('masquerade', 'net_addr_mask', prefix='  ')|load_yaml %}
  {{ n }}
{%- endfor %}
apt-cacher-ng:
  bind_address: "{{ net_list('masquerade', 'interface_ip')|load_yaml|join(' ') }}"
default: 
  ip_address: "{{ net_addr(interfaces['isobr0']) }}"
  netmask: "{{ interfaces['isobr0'].netmask }}"
  range_start: "{{ net_calc(interfaces['isobr0'], 2) }}"
  range_end: "{{ net_calc(interfaces['isobr0'], -1) }}"

{% endload %}

/srv/salt/salt-shared/network/test.log:
  file.managed:
    - contents: |
{{ defaults|yaml(false)|indent(8, true) }}

