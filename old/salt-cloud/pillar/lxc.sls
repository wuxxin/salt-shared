lxc.container_profile:
  centos:
    template: centos
    backing: lvm
    vgname: vg1
    lvname: lxclv
    size: 10G
  ubuntu:
    template: ubuntu
    backing: lvm
    vgname: vg1
    lvname: lxclv
    size: 10G

lxc.network_profile:
  default:
    eth0:
      link: lxcbr0
      type: veth
      flags: up
  centos:
    eth0:
      link: br0
      type: veth
      flags: up
  