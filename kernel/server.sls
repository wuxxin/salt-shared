include:
  - kernel.running
  - kernel.modules
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.cgroup
  - systemd.cgroup-accounting
  - kernel.kvm

kernel_server_nop:
  test:
    - nop
