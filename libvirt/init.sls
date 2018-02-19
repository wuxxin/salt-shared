include:
  - kernel
  - kernel.cgroup
  
# KVM: vm.swappiness = 0 The kernel will swap only to avoid an out of memory condition
# Rationale: memory is given to the other domains, so we dont want the host to swap guest memory
vm.swappiness:
  sysctl.present:
    - value: 0

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - qemu-kvm
      - ovmf
    - require:
      - sls: kernel.cgroup

  service.running:
    - name: libvirt-bin
    - enable: True
    - require:
      - pkg: libvirt
