include:
  - remotefs
  - .kvm
  - .images
  - .kernel

libvirt:
  pkg.installed:
    - pkgs:
      - ubuntu-virt-server
      - libvirt-bin
      - qemu-kvm
      - virt-viewer
      - virt-manager
      - virtinst
      - virt-top
      - python-libvirt
      - python-spice-client-gtk
      - python-guestfs
      - libguestfs-tools
      - nbdkit
      - lvm2
      - multipath-tools
      - bridge-utils
      - vlan
  file:
    - managed
    - name: /etc/sysconfig/libvirtd
    - contents: 'LIBVIRTD_ARGS="--listen"'
    - require:
      - pkg: libvirt
  libvirt:
    - keys
    - require:
      - pkg: libvirt
  service:
    - running
    - name: libvirtd
    - require:
      - pkg: libvirt
      - libvirt: libvirt
    - watch:
      - file: libvirt

