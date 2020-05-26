{% from "kernel/defaults.jinja" import settings with context %}

{% load_yaml as netfilter_list %}
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

{% if grains['virtual'] != 'LXC' %}
/etc/modules-load.d/netfilter.conf:
  file.managed:
    - contents: |
  {%- for i in netfilter_list %}
        {{ i }}
  {%- endfor %}

netfilter-kernel-modules:
    kmod.present:
      - mods:
  {%- for i in netfilter_list %}
        - {{ i }}
  {%- endfor %}

{% endif %}
