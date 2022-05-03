include:
  - kernel.running
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.network
  - kernel.lxc
  - qemu
  - libvirt
  - systemd.cgroup

kernel_server_nop:
  test:
    - nop
