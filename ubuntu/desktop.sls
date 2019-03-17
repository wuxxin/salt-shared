include:
  - ubuntu
  - ubuntu.reporting.disabled
  - ubuntu.hibernate

install_desktop:
  - pkgs.installed:
    - pkgs:
      - xserver-xorg-hwe-18.04
      - gnome.core
      - gnome
      - vanilla-gnome-desktop
