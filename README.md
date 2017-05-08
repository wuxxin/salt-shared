## salt-shared - useful Salt states

This is a collection of saltstack states
as a result of me learning saltstack.
Both quality and style differ from state to state,
most states are working, some not.

It is already in a useful condition,
but it lacks documentation beside a few README.md .


### What can you do with it:

 * Target Platform: Ubuntu LTS (16.04), 14.04
   * many states also work with older/newer ubuntu and other debian based distros.
   * some states may work with other linux distros
   * Windows Platform: there is some support for windows and windows packages (using chocolatey as pkg manager)

 * Features to look at:
   * [`storage`](storage):
     * setup harddisk storage, features parted, mdadm, crypt, lvm, format, mount, swap, directories, relocate services
   * [`network`](network):
     * setup network, calculate network adresses netmasks a.o.
   * [`http_proxy`](http_proxy):
     * [`.server`](http_proxy/server.sls): install polipo
     * [`.client_use_proxy`](http_proxy/client_use_proxy.sls), [`.client_no_proxy`](http_proxy/client_no_proxy.sls),: setup http_proxy, HTTP_PROXY for: apt, docker, profile.d, sudoers.d, dokku
   * [`roles.dns`](roles/dns/): caching (unbound) and authorative dns (knot) server
   * [`roles.dokku`](roles/dokku/): dokku PAAS
   * [`roles.imgbuilder`](/roles/imgbuilder):
     * [`.packer`](roles/imgbuilder/packer/): use packer on qemu/kvm and vagrant on libvirt/kvm to setup virtual machines from scratch on a KVM enabled kernel
     * [`.preseed`](roles/imgbuilder/preseed/): make customized preseed installations that have mdadm/luks/lvm in an ssh headless setup
     * [`.vagrant`](roles/imgbuilder/vagrant): deploy these easy to setup vagrant machines as production machines and control them via saltstack
   * [`roles.desktop`](roles/desktop):
     * everything needed from a desktop base installation for developing (ubuntu 16.04+14.04)

### How to start:

 * look at [`salt-top.example`](salt-top.example) and [`pillar-top.example`](pillar-top.example) for a start

 * without a saltmaster:
   * fork/download salt-setup-template and look there for more info

 * with a saltmaster:
   * include this repository as a salt directory and point salt master config to it


### directory layout:

 * [`/salt-top.example`](salt-top.example): Example states top file
 * [`/pillar-top.example`](pillar-top.example): Example pillar data

 * `/.*`      : Low level salt states
 * [`/roles/*`](/roles/) : High level salt states
 * [`/roles/desktop/*`](/roles/desktop/)
            : High level salt states used for desktop setups

 * [`/repo/*`](/repo/)  : distribution specific repository setup
 * [`/win/*`](/win/)   : Windows specific salt states
