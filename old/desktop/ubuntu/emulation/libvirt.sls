include:
  - libvirt

virt-tools:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-guestfs
      - ssh-askpass-gnome
      - virt-manager
      - virt-viewer
      - spice-client-gtk
    - require:
      - sls: libvirt
