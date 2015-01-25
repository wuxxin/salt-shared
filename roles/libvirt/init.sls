#!jinja|yaml

include:
  - remotefs
  - .kernel
  - .grub
  - .storage
  - .network
  - .salt_master

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - libguestfs-tools
      - ubuntu-virt-server
      - qemu-kvm
      - python-openssl {# is needed for states.libvirt.keys #}
      - gnutls-bin {# is needed for states.libvirt.keys #}
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
      - cgroup-bin {# library and kernel support is needed, bin package catches requisites #}
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
    - enable: True
    - require:
      - pkg: libvirt
      - libvirt: libvirt
      - sls: roles.libvirt.storage
      - sls: roles.libvirt.network
      - sls: roles.libvirt.kernel
      - sls: roles.libvirt.grub
    - watch:
      - file: libvirt

