{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}  
include:
  - .big-inotify
  - .big-ipv4-arp-cache
  - .big-ipv6-arp-cache
  - .big-max-map-count
{%- endif %}

sysctl_nop:
  test:
    - nop
