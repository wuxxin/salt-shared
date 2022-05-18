include:
  - kernel
  - kernel.sysctl.cgroup-userns-clone
  - kernel.network
  - systemd.cgroup

qemu:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Ubuntu' %}
      - qemu-block-extra
      - qemu-kvm
      - qemu-system
      - qemu-system-x86
      - qemu-user
      - qemu-user-binfmt
      - qemu-utils
      - ovmf
      - libosinfo-bin
{% elif grains['os'] == 'Manjaro' %}
      - qemu-desktop
      - qemu-guest-agent
      - edk2-ovmf
      - swtpm
      - mkosi
{% endif %}
