{%- set kernelmajor= int(grains['kernelrelease'][1]) %}
{%- set kernelminor= int(grains['kernelrelease']|regex_replace('^[^.]+\.([^.])+\..+', '\\1')) %}

{%- if (kernelmajor >= 5) or (kernelmajor == 4 and kernelminor >= 9) %}
tcp_bbr:
  file.managed:
    - name: /etc/modules-load.d/tcp.conf
    - contents: |
        tcp_bbr
  kmod:
    - present

net.core.default_qdisc:
  sysctl.present:
    - value: fq
    - require:
      - kmod: tcp_bbr

net.ipv4.tcp_congestion_control:
  sysctl.present:
    - value: bbr
    - require:
      - sysctl: net.core.default_qdisc
{%- else %}

tcp_bbr_nop:
  test:
    - nop

{%- endif %}
