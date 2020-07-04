include:
  - kernel.running
  - kernel.sysctl
  - kernel.cgroup
  - kernel.limits
  - kernel.modules
  - kernel.swappiness
  - systemd.cgroup-accounting

kernel_server_nop:
  test:
    - nop
