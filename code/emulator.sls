include:
  - kernel.network
  - kernel.sysctl.cgroup-userns-clone
  - systemd.cgroup

qemu:
  pkg.installed:
    - pkgs:
      # qemu-desktop - QEMU setup for desktop environments
      - qemu-desktop
      # add arm, mips and xtensa (esp8266, esp32) emulation
      - qemu-system-arm
      - qemu-system-mips
      - qemu-system-xtensa
      - qemu-guest-agent
      # edk2-ovmf - Firmware for Virtual Machines (x86_64, i686)
      - edk2-ovmf
      # swtpm - TPM emulator with socket, character device, and Linux CUSE interface
      - swtpm
      # mkosi - Build Legacy-Free OS Images
      - mkosi
      # guestfs-tools - Tools for accessing and modifying guest disk images
      - guestfs-tools

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt
      - libvirt-dbus
      - libvirt-python
    - require:
      - sls: kernel.network
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: qemu
