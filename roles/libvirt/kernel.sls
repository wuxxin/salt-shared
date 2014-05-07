vm.swappiness:
  sysctl.present:
    - value: 0

vm.zone_reclaim_mode:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-call-arptables:
  sysctl.present:
    - value: 0
