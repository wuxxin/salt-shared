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
network-interface-{{ item }}:
  network.managed:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}: {{ subvalue }}
{% endfor %}
    - require_in:
      - file: config_interfaces_override
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



{%- macro net_addr(interface) %}
{{- salt.extip.start_from_net(salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_short(interface) %}
{{- salt.extip.short_from_net(
    salt.extip.combine_net_mask(
        salt.extip.start_from_net(
            salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_addr_cidr(interface) %}
{{- salt.extip.netcidr_from_net(salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_broadcast(interface) %}
{{- salt.extip.end_from_net(salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)) }}
{%- endmacro %}


{%- macro net_reverse(interface) %}
{{- salt.extip.reverse_from_net(
    salt.extip.combine_net_mask(
        salt.extip.start_from_net(
            salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_reverse_short(interface) %}
{{- salt.extip.short_reverse_from_net(
    salt.extip.combine_net_mask(
        salt.extip.start_from_net(
            salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)
        ), interface.netmask)
    ) }}
{%- endmacro %}


{%- macro net_calc(interface, offset) %}
{{- salt.extip.calc_ip_from_net(
    salt.extip.combine_net_mask(
        salt.extip.start_from_net(
            salt.extip.combine_net_mask(interface.ipaddr, interface.netmask)
        ), interface.netmask)
    , offset) }}
{%- endmacro %}


{%- macro net_list(group, format=None, groups=None, interfaces=None ) %}
{%- if groups == None %}
{%- set groups = salt['pillar.get']('network:groups', {}) %}
{%- endif %}
{%- if interfaces == None %}
{%- set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{%- endif %}
{%- set out=[] %}
{%- for n in groups[group] %}
{%- if   format == 'interface_ip' %}{%- do      out.append(interfaces[n].ipaddr) %}
{%- elif format == 'net_addr' %}{%- do          out.append(net_addr(interfaces[n])) %}
{%- elif format == 'net_short' %}{%- do         out.append(net_short(interfaces[n])) %}
{%- elif format == 'net_addr_cidr' %}{%- do     out.append(net_addr_cidr(interfaces[n])) %}
{%- elif format == 'net_broadcast' %}{%- do     out.append(net_broadcast(interfaces[n])) %}
{%- elif format == 'net_reverse' %}{%- do       out.append(net_reverse(interfaces[n])) %}
{%- elif format == 'net_reverse_short' %}{%- do out.append(net_reverse_short(interfaces[n])) %}
{%- endif %}
{%- endfor %}
{{- out }}
{%- endmacro %}


{#
def combine_net_mask(net, mask):
def cidr_from_net(combined):
def start_from_net(combined):
def end_from_net(combined):
def netcidr_from_net(combined):
def short_from_net(combined):
def reverse_from_net(combined):
def short_reverse_from_net(combined):
def size_from_net(combined):
def calc_ip_from_net(combined, offset):
#}
