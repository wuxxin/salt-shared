include:
  - .big-inotify
{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}  
  - .big-ipv4-arp-cache
{%- endif %}

sysctl_nop:
  test:
    - nop
