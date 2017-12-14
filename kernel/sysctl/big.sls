include:
{%- if salt['grains.get']('virtual', 'unknown') != 'LXC' %}  
  - .big-inotify
  - .big-ipv4-arp-cache
{%- endif %}

sysctl_nop:
  test:
    - nop
