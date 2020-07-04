{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}
include:
  - .big-inotify
  - .big-ipv4-arp-cache
  - .big-ipv6-arp-cache
  - .big-max-map-count
  - .big-max-keys
  - .restrict-dmesg
{%- endif %}

sysctl_nop:
  test:
    - nop
