include:
  - kernel.running
  - kernel.modules
  - kernel.sysctl
  - kernel.cgroup
  - kernel.limits
  - kernel.swappiness
  - systemd.cgroup-accounting

kernel_server_nop:
  test:
    - nop
