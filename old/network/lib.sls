
# for easy usage import sys_network,interfaces,routes
# in addition to the macros you want
{% set sys_network = salt['pillar.get']('network:system', {}) %}
{% set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{% set routes = salt['pillar.get']('network:routes', {}) %}

# configuring macros
{% macro config_system(sys_network) %}

{% if sys_network %}
network-system:
  network.system:
{% for item, data in sys_network.iteritems() %}
    - {{ item }}: {{ data }}{% endfor %}
{% endif %}

{% endmacro %}


{% macro config_interfaces(interfaces) %}

{% for item, data in interfaces.iteritems() %}
{% if data['type']|d('virtual') != 'virtual' %}
network-interface-{{ item }}:
  network.managed:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}: {{ subvalue }}
{% endfor %}
    - require_in:
      - file: config_interfaces_override
{% endif %}
{% endfor %}

config_interfaces_override:
  file:
    - absent
    - name: /etc/init/networking.override

{% endmacro %}


{% macro config_routes(routes) %}

{% for interface, data in routes.iteritems() %}
network-route-{{ interface }}:
{% if grains['os_family'] == 'Debian' %}
  file.replace:
    - name: /etc/network/interfaces
    - flags:
      - MULTILINE
      - IGNORECASE
    - bufsize: file
    - pattern: "^iface {{ interface }} inet ([a-z0-9]+)[ ]*$(^[ ]+(up)|(down) ip route .+$)?"
    - repl: "iface {{ interface }} inet \\1\\n{% for ipaddr, subdata in data.iteritems() %}    up  ip route add {{ ipaddr }}/{{ subdata.netmask }} dev {{ interface }}\n    down ip route del {{ ipaddr }}/{{ subdata.netmask }} dev {{ interface }}\n{% endfor %}"
    - require_in:
      - file: /etc/init/networking.override
  cmd.run:
    - name: "ifup --force {{ interface }}"
    - require:
      - file: network-route-{{ interface }}
{% else %}
  network.routes:
    - name: {{ interface }}
    - routes:
{% for ipaddr, subdata in data.iteritems() %}
      - name: route-{{ ipaddr }}
        ipaddr: {{ ipaddr }}
{% for item, value in subdata.iteritems() %}
        {{ item }}: {{ value }}{% endfor %}{% endfor %}
    - require_in:
      - file: config_routes_override
{% endif %}
{% endfor %}

config_routes_override:
  file:
    - absent
    - name: /etc/init/networking.override

{% endmacro %}


{% macro change_dns(interface, oldconfig, newdns) %}

change_network_managed_dns:
  network.managed:
    - name: {{ interface }}
    - dns:
      - {{ newdns }}
{%- for sub, subvalue in oldconfig.iteritems() %}
{% if sub != 'dns' %}
    - {{ sub }}: {{ subvalue }}
{%- endif %}
{%- endfor %}

update_library:
  cmd.run:
    - name: resolvconf --enable-updates; resolvconf -u
    - require:
      - network: change_network_managed_dns

{% endmacro %}



# ip and network addresses filtering
{%- macro net_addr(interface) %}
{{- salt['extipv4.start_from_net'](salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_short(interface) %}
{{- salt['extipv4.short_from_net'](
    salt['extipv4.combine_net_mask'](
        salt['extipv4.start_from_net'](
            salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_addr_cidr(interface) %}
{{- salt['extipv4.netcidr_from_net'](salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_broadcast(interface) %}
{{- salt['extipv4.end_from_net'](salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_reverse(interface) %}
{{- salt['extipv4.reverse_from_net'](
    salt['extipv4.combine_net_mask'](
        salt['extipv4.start_from_net'](
            salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_reverse_short(interface) %}
{{- salt['extipv4.short_reverse_from_net'](
    salt['extipv4.combine_net_mask'](
        salt['extipv4.start_from_net'](
            salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_calc(interface, offset) %}
{{- salt['extipv4.calc_ip_from_net'](
    salt['extipv4.combine_net_mask'](
        salt['extipv4.start_from_net'](
            salt['extipv4.combine_net_mask'](interface.ipaddr, interface.netmask)
        ), interface.netmask)
    , offset) }}
{%- endmacro %}


{%- macro net_list(group, format=None, groups=None, interfaces=None) %}
{%- if groups == None %}
{%- set groups = salt['pillar.get']('network:groups', {}) %}
{%- endif %}
{%- if interfaces == None %}
{%- set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{%- endif %}
{{- salt['extipv4.net_list'](format, groups[group], interfaces, kwargs) }}
{%- endmacro %}
