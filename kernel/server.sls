include:
  - kernel.running
  - kernel.sysctl
  - kernel.cgroup
  - kernel.limits
  - kernel.modules
  - kernel.swappiness

kernel_big_nop:
  test:
    - nop
