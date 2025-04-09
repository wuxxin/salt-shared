include:
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.network
  - kernel.lxc
  - systemd.cgroup

kernel_server_nop:
  test:
    - nop
