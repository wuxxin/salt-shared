{# 
ARP cache settings for a highly loaded docker swarm
https://blog.codeship.com/running-1000-containers-in-docker-swarm/
https://www.e-rave.nl/kernel-neighbour-table-overflow
#}

{# the minimum number of entries to keep in the ARP cache #}
net.ipv6.neigh.default.gc_thresh1:
  sysctl.present:
    - value: 2048 {# 128 #}

{# the soft maximum number of entries to keep in the ARP cache #}
net.ipv6.neigh.default.gc_thresh2:
  sysctl.present:
    - value: 6144 {# 512 #}

{# the hard maximum number of entries to keep in the ARP cache #}
{# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers. Otherwise, you will get the error neighbour: ndisc_cache: neighbor table overflow! when the ARP table gets full and those containers will not be able to get a network configuration. #}

net.ipv6.neigh.default.gc_thresh3:
  sysctl.present:
    - value: 8192 {# 1024 #}

