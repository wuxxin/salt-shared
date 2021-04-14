{% from "opennebula/defaults.jinja" import settings %}

include:
  - kernel.server
  - kernel.kvm
  - kernel.lxc
  - kernel.network
  - libvirt

opennebula-ppa:
  pkgrepo.managed:
    - name: deb http://downloads.opennebula.org/repo/6.0/{{ grains['os'] }}/{{ grains['osrelease'] }} stable opennebula
    - key: https://downloads.opennebula.io/repo/repo.key

opennebula-frontend:
  pkg.installed:
    - pkgs:
      - opennebula
      - opennebula-sunstone
      - opennebula-fireedge
      - opennebula-gate
      - opennebula-flow
      - opennebula-provision
    - require:
      - pkgrepo: opennebula-ppa

opennebula-node-kvm:
  pkg.installed:
    - pkgs:
      - opennebula-node-kvm
    - require:
      - pkgrepo: opennebula-ppa
      - sls: kernel.network
      - sls: libvirt

opennebula-node-lxc:
  pkg.installed:
    - pkgs:
      - opennebula-node-lxc
    - require:
      - pkgrepo: opennebula-ppa
      - sls: kernel.network
      - sls: kernel.lxc

opennebula-node-firecracker:
  pkg.installed:
    - pkgs:
      - opennebula-node-firecracker
    - require:
      - pkgrepo: opennebula-ppa
      - sls: kernel.network
      - sls: kernel.kvm
