{% from 'arch/lib.sls' import aur_install with context %}

include:
  - code.emulator
  - android.tools

emulator-libvirt:
  pkg.installed:
    - pkgs:
      - gnome-boxes    
      - virt-manager
      - virt-viewer
      - spice-gtk
    - require:
      - sls: code.emulator
{% load_yaml as pkgs %}
      - virtio-win
      # virtio-win - virtio drivers for Windows 7 and newer guests
{% endload %}
{{ aur_install("emulator-libvirt-aur", pkgs, require= ["pkg: emulator-libvirt" ] ) }}


{% load_yaml as pkgs %}
      # android-studio-canary - The Official Android IDE (Canary branch)
      - android-studio-canary
{% endload %}
{{ aur_install("emulator-android-aur", pkgs, require= "sls: code.emulator") }}

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
