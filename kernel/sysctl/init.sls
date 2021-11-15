{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
include:
  - .big-inotify
  - .big-ipv4-arp-cache
  - .big-ipv6-arp-cache
  - .big-max-map-count
  - .big-max-keys
  - .cgroup-userns-clone
  - .restrict-dmesg
{% endif %}

sysctl_nop:
  test:
    - nop
