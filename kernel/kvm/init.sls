include:
  - kernel
  - kernel.swappiness
  - kernel.sysctl.cgroup-userns-clone
  - kernel.network
  - systemd.cgroup

qemu:
  pkg.installed:
    - pkgs:
      - qemu-block-extra
      - qemu-kvm
      - qemu-system
      - qemu-system-x86
      - qemu-user
      - qemu-user-binfmt
      - qemu-utils
      - ovmf
      - libosinfo-bin
