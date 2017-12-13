include:
  - kernel.cgroup
  - libvirt
  - desktop.emulation.ppa

qemu:
  pkg.installed:
    - pkgs:
      - qemu
    - require:
      - sls: kernel.cgroup

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
      - sls: desktop.emulation.ppa

# vnc , rdp, ssh
remmina:
  pkg.installed:
    - pkgs:
      - remmina
      - remmina-plugin-vnc
      - remmina-plugin-gnome
      - remmina-plugin-rdp
