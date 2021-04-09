{% from "opennebula/defaults.jinja" import settings %}

include:
  - kernel.server
  - kernel.kvm

opennebula:
https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
source /etc/os-release
echo "deb https://deb.nodesource.com/node_12.x ${VERSION_CODENAME} main" >/etc/apt/sources.list.d/nodesource.list
apt-get update

opennebula-node-req:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - ebtables

opennebula-lxc-req:
  pkg.installed:
    - pkgs:
      - uidmap
      - lxc-utils
      - lxc-templates
    - require:
      - sls: kernel.server

opennebula-node-kvm:
  pkg.installed:
    - pkgs:
      -

opennebula-node-lxc:
  pkg.installed:
    - pkgs:
      -

opennebula-node-firecracker:
  pkg.installed:
    - pkgs:
      -
