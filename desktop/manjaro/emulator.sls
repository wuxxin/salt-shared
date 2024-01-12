{% from 'aur/lib.sls' import aur_install with context %}

include:
  - qemu
  - libvirt
  - containers
  - android.tools

emulator-qemu:
  pkg.installed:
    - pkgs:
      - qemu-desktop
      # add arm, mips and xtensa (esp8266, esp32) emulation
      - qemu-system-arm
      - qemu-system-mips
      - qemu-system-xtensa
      - gnome-boxes
    - require:
      - sls: qemu

{% load_yaml as pkgs %}
      - virtio-win
      # virtio-win - virtio drivers for Windows 7 and newer guests
{% endload %}
{{ aur_install("emulator-qemu-aur", pkgs, require= ["pkg: emulator-qemu" ] ) }}

emulator-libvirt:
  pkg.installed:
    - pkgs:
      - virt-manager
      - virt-viewer
      - spice-gtk
    - require:
      - sls: libvirt

cross-compiler-arm:
  pkg.installed:
    - pkgs:
      - arm-none-eabi-binutils
      - arm-none-eabi-gcc
      - arm-none-eabi-newlib 

{% load_yaml as pkgs %}
      - android-studio-canary
{% endload %}
{{ aur_install("emulator-android-aur", pkgs,
    require= ["sls: qemu", "sls: libvirt", "sls: containers" ] ) }}

# chown_to_main_user:
  # FIXME chwon /opt/android-sdk to mainuser:mainuser
  # FIXME as mainuser: symlink lib and lib64 to /opt/android-sdk/emulator/qemu/linux-x86_64
  #  for i in lib lib64; do ln -s ../../$i /opt/android-sdk/emulator/qemu/linux-x86_64/$i; done

emulator-windows:
  pkg.installed:
    - pkgs:
      # wine - compatibility layer for running Windows programs
      - wine
      # wine-gecko - Wine's built-in replacement for Microsoft's Internet Explorer
      - wine-gecko
      # vkd3d - Direct3D 12 to Vulkan translation library By WineHQ
      - vkd3d
      # bottles - tailored windows configurations
      - bottles

emulator-windows-games:
  pkg.installed:
    - pkgs:
      # arch-gaming-meta - Meta package for Gaming including Steam, Lutris, Wine, essential gaming+proprietary libraries & several other dependencies
      - arch-gaming-meta

emulator-arcade:
  pkg.installed:
    - pkgs:
      - retroarch
      - libretro-overlays
      - mame
