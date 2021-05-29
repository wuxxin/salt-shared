include:
  - libvirt

virt-tools:
  pkg.installed:
    - pkgs:
      - python3-guestfs
      - ssh-askpass-gnome
      - virt-manager
      - virt-viewer
      - spice-client-gtk
    - require:
      - sls: libvirt
