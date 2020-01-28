include:
  - libvirt
  
virt-tools:
  pkg.installed:
    - pkgs:
      - virt-manager
      - python3-guestfs
      - ssh-askpass-gnome
      - virt-viewer
      - spice-client-gtk
    - require:
      - sls: libvirt
