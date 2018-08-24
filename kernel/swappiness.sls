# swappiness=60 (Default)
# swappiness=0: Kernel >= 3.5: disables swappiness
# swappiness=1: Kernel >= 3.5: minimum swappiness without disabling it entirely.
# swappiness=10: Less aggressive swap than the default of 60
# swappiness=100: aggressively swap processes out of physical memory

# General: use swappiness=10 for less aggresive swappiness

# while using KVM and other full virtualization: swappiness=1 
# rationale: memory is given to the other domains, so we dont want the host to swap guest memory

{% set swappiness = salt['pillar.get']('kernel:swappiness', 10) %}

vm.swappiness:
  sysctl.present:
    - value: {{ swappiness }}

    