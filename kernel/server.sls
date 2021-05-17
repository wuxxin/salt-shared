include:
  - kernel.running
  - kernel.modules
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.cgroup
  - systemd.cgroup
  - kernel.network
  - kernel.kvm
  - kernel.lxc

kernel_server_nop:
  test:
    - nop
