include:
  - kernel.network
  - libvirt.qemu

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt
      - libvirt-dbus
      - libvirt-python
    - require:
      - sls: kernel.network
      - sls: libvirt.qemu
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - pkg: libvirt
