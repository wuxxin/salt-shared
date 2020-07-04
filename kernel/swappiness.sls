# swappiness=60 (Default)
# swappiness=0: disables swappiness
# swappiness=1: minimum swappiness without disabling it entirely.
# swappiness=10: Less swapping than the default of 60
# swappiness=100: More swapping processes out of physical memory

# in general, on modern linux kernels with a psi controlled oom daemon, swap mitigates peak load
# under some cirumstances while using KVM or other virtualization: swappiness=1 may be desired.
# rationale: memory is given to the other domains, so we dont want the host to swap guest memory

{% set swappiness = salt['pillar.get']('kernel:swappiness', 60) %}

vm.swappiness:
  sysctl.present:
    - value: {{ swappiness }}
