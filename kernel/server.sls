include:
  - kernel.running
  - kernel.modules
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.network
  - kernel.kvm
  - kernel.lxc
  - systemd.cgroup

kernel_server_nop:
  test:
    - nop
