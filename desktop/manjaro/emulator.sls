{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - android.tools
  - containers
  - qemu
  - libvirt

{% load_yaml as pkgs %}
      - android-sdk
      - android-sdk-platform-tools
      - android-sdk-cmdline-tools-latest
      - android-emulator
      # platform versions
      - android-sources-29
      - android-platform-29
      - android-google-apis-playstore-x86-64-system-image-29
{% endload %}
{{ pamac_install("emulator-android-aur", pkgs,
    require= ["sls: qemu", "sls: libvirt", "sls: containers" ] ) }}

emulator-qemu:
  pkg.installed:
    - pkgs:
      - gnome-boxes
    - require:
      - sls: qemu

emulator-libvirt:
  pkg.installed:
    - pkgs:
      - virt-manager
      - virt-viewer
      - spice-gtk
    - require:
      - sls: libvirt

emulator-arcade:
  pkg.installed:
    - pkgs:
      - retroarch
      - libretro-overlays
      - mame

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
