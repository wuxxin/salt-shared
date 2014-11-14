include:
  - remotefs
  - .kernel
  - .grub
  - .storage
  - .network

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - libguestfs-tools
      - ubuntu-virt-server
      - qemu-kvm
      - python-openssl
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
      - cgroup-bin
      - multipath-tools
      - bridge-utils
      - vlan
  file.replace:
    - name: /etc/default/libvirt-bin
    - pattern: '#?start_libvirtd=.+'
    - repl: 'start_libvirtd="yes"'
    - require:
      - pkg: libvirt
  libvirt:
    - keys
    - require:
      - pkg: libvirt
  service:
    - running
    - name: libvirt-bin
    - require:
      - pkg: libvirt
      - libvirt: libvirt
    - watch:
      - file: libvirt

