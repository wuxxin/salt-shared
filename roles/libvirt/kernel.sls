# KVM: vm.swappiness = 0 The kernel will swap only to avoid an out of memory condition
# Rationale: memory is given to the other domains, so we dont want the guest to manage the memory
vm.swappiness:
  sysctl.present:
    - value: 0

# KVM: useful for same page merging and huge pages on guest
vm.zone_reclaim_mode:
  sysctl.present:
    - value: 0

#
net.bridge.bridge-nf-call-arptables:
  sysctl.present:
    - value: 0
