{% from 'arch/lib.sls' import aur_install with context %}

include:
  - kernel.network
  - kernel.sysctl.cgroup-userns-clone
  - systemd.cgroup
  - android.tools

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
      - pkg: qemu
      - sls: kernel.network
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: libvirt

emulator-libvirt:
  pkg.installed:
    - pkgs:
      - gnome-boxes    
      - virt-manager
      - virt-viewer
      - spice-gtk
    - require:
      - pkg: libvirt
{% load_yaml as pkgs %}
      - virtio-win
      # virtio-win - virtio drivers for Windows 7 and newer guests
{% endload %}
{{ aur_install("emulator-libvirt-aur", pkgs, require= ["pkg: emulator-libvirt" ] ) }}


{% load_yaml as pkgs %}
      # android-studio-canary - The Official Android IDE (Canary branch)
      - android-studio-canary
{% endload %}
{{ aur_install("emulator-android-aur", pkgs, require= "pkg: emulator-libvirt") }}

emulator-windows:
  pkg.installed:
    - pkgs:
      # wine - compatibility layer for running Windows programs
      - wine
      # wine-gecko - Wine's built-in replacement for Microsoft's Internet Explorer
      - wine-gecko
      # vkd3d - Direct3D 12 to Vulkan translation library By WineHQ
      - vkd3d

{% load_yaml as pkgs %}
      # bottles - tailored windows configurations
      - bottles
      # arch-gaming-meta - Meta package for Gaming including Steam, Lutris, Wine, essential gaming+proprietary libraries & several other dependencies
      - arch-gaming-meta
{% endload %}
{# aur_install("emulator-windows-aur", pkgs, require= "pkg:emulator-windows" ) #}

emulator-arcade:
  pkg.installed:
    - pkgs:
      - retroarch
      - libretro-overlays
      - mame
