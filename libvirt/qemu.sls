include:
  - kernel
  - kernel.sysctl.cgroup-userns-clone
  - kernel.network
  - systemd.cgroup

qemu:
  pkg.installed:
    - pkgs:
      - qemu-desktop
      - qemu-guest-agent
      - edk2-ovmf
      - swtpm
      - mkosi
