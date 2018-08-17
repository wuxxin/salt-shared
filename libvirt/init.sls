include:
  - kernel
  - kernel.cgroup
  - kernel.swappiness
  
libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - systemd-container
      - qemu
      - qemu-kvm
      - ovmf
    - require:
      - sls: kernel.cgroup

  service.running:
    - name: libvirt-bin
    - enable: True
    - require:
      - pkg: libvirt
