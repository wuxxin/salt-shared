include:
  - kernel.headers_tools
  - kernel.sysctl
  - kernel.limits
  - kernel.swappiness
  - kernel.network
  - kernel.lxc
  - libvirt
  - systemd.cgroup

kernel_server_nop:
  test:
    - nop
