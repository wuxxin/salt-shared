# state network

## how to use

* activate extipv4.py (from _modules) to add additional functions
* make a pillar (see example-pillar.sls)
* use "type: virtual" to make a interface not used for network.managed, but for other purposes (eg. net_list)
* use lib.sls for advanced network functions like: net_addr, net_calc, net_list 

## pillar usage

* Basic Usage:
```
{% import_yaml "server/network.sls" as n with context %}

{{ n.network.interfaces['resbr0'].ipaddr }}
{{ n.network.interfaces['eth0']['dns-search'] }}
```

* Extended Usage:

  * copy lib.sls to pillar/lib/network.sls to use functionality in pillar

```
{% import_yaml "server/network.sls" as n with context %}
{% from "lib/network.sls" import net_addr, net_calc, net_list with context %}

vpn_net: {{ net_addr(n.network.interfaces['vpnnet']) }}
vpn_mask: {{ n.network.interfaces['vpnnet'].netmask }}
dns_ip: {{ net_addr(n.network.interfaces['resbr0']) }}
ip_routes:
{%- for i in net_list('route', 'net_addr_mask', n.network.groups, n.network.interfaces, prefix='  ')|load_yaml %}
  {{ i }}
{%- endfor %}

range_start: {{ net_calc(n.network.interfaces['iroutebr0'], 64) }}
range_end: {{ net_calc(n.network.interfaces['iroutebr0'], -1) }}

```
