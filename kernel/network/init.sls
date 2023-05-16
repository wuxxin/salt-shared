{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}

{% load_yaml as network_list %}
- br_netfilter
- ip6_tables
- ip_tables
- ip_vs
- ip_vs_rr
- ip_vs_sh
- ip_vs_wrr
- netlink_diag
- nf_conntrack
- nf_nat
- xt_conntrack
{% endload %}

/etc/modules-load.d/network.conf:
  file.managed:
    - contents: |
  {%- for i in network_list %}
        {{ i }}
  {%- endfor %}
  kmod.present:
    - mods:
  {%- for i in network_list %}
      - {{ i }}
  {%- endfor %}
{% endif %}

network-tools:
  pkg.installed:
    - pkgs:
      - iptables-nft
      - dnsmasq
      - openbsd-netcat
      - bridge-utils
      - ipset
      - netctl
      - vde2
