include:
  - kernel
  - kernel.cgroup
  - kernel.swappiness


qemu:
  pkg.installed:
    - pkgs:
      - qemu-block-extra
      - qemu-kvm
      - qemu-system
      - qemu-system-x86
      - qemu-user
      - qemu-user-binfmt
      - qemu-utils
      - ovmf
    - require:
      - sls: kernel.cgroup

libvirt:
  pkg.installed:
    - pkgs:
{%- if grains['osmajorrelease']|int < 18 %}
      - libvirt-bin
{%- else %}
      - libvirt-clients
      - libvirt-daemon
      - libvirt-daemon-system
      - libvirt-daemon-driver-storage-zfs
{%- fi %}
    - require:
      - pkg: qemu
  service.running:
{%- if grains['osmajorrelease']|int < 18 %}
    - name: libvirt-bin
{%- else %}
    - name: libvirtd
{%- fi %}
    - enable: True
    - require:
      - pkg: libvirt
