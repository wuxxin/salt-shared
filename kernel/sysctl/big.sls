{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}  
include:
  - .big-inotify
  - .big-ipv4-arp-cache
{%- endif %}

sysctl_big_nop:
  test:
    - nop
