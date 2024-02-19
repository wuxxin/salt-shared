{% from "opennebula/defaults.jinja" import settings %}

include:
  - kernel.server
  - kernel.network
  - kernel.lxc
  - qemu
  - libvirt

opennebula-ppa:
  pkgrepo.managed:
    - name: deb http://downloads.opennebula.org/repo/6.0/{{ grains['os'] }}/{{ grains['osrelease'] }} stable opennebula
    - key: https://downloads.opennebula.io/repo/repo.key
    - require_in:
      - pkg: opennebula-frontend
      - pkg: opennebula-node-kvm
      - pkg: opennebula-node-lxc
      - pkg: opennebula-node-firecracker

opennebula-frontend:
  pkg.installed:
    - pkgs:
      - opennebula
      - opennebula-sunstone
      - opennebula-fireedge
      - opennebula-gate
      - opennebula-flow
      - opennebula-provision

opennebula-node-kvm:
  pkg.installed:
    - pkgs:
      - opennebula-node-kvm
    - require:
      - sls: kernel.network
      - sls: libvirt

opennebula-node-lxc:
  pkg.installed:
    - pkgs:
      - opennebula-node-lxc
    - require:
      - sls: kernel.network
      - sls: kernel.lxc

opennebula-node-firecracker:
  pkg.installed:
    - pkgs:
      - opennebula-node-firecracker
    - require:
      - sls: kernel.network
      - sls: qemu
