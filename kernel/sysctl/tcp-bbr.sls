{%- set kernelmajor= int(grains['kernelrelease'][1]) %}
{%- set kernelminor= int(grains['kernelrelease']|regex_replace('^[^.]+\.([^.])+\..+', '\\1')) %}

{# see
https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git/commit/?id=0f8782ea14974ce992618b55f0c041ef43ed0b78
https://www.heise.de/newsticker/meldung/Googles-TCP-Flusskontrolle-BBR-bremst-fremde-Downloads-aus-4050865.html
#}

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
