include:
  - cgroup
  - libvirt
  - roles.desktop.emulation.ppa

qemu:
  pkg.installed:
    - pkgs:
      - qemu
    - require:
      - sls: cgroup

virt-tools:
  pkg.installed:
    - pkgs:
      - python-spice-client-gtk
      - python-gnomekeyring
      - python-guestfs
      - ssh-askpass
      - virt-viewer
      - spice-client-gtk

# xserver-xspice
virt-manager:
  pkg.installed:
    - pkgs:
      - virt-manager
    - require:
      - pkg: virt-tools
      - sls: roles.desktop.emulation.ppa

# vnc , rdp, ssh
remmina:
  pkg.installed:
    - pkgs:
      - remmina
      - remmina-plugin-vnc
      - remmina-plugin-gnome
      - remmina-plugin-rdp
