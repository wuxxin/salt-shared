## salt-shared - useful Salt states

This is a collection of saltstack states
as a result of me learning saltstack.
Both quality and style differ from state to state,
most states are working, some not.

It is already in a useful condition,
but it lacks documentation beside a few README.md .


### What can you do with it:

 * Target Platform: Ubuntu LTS 16.04 (xenial), 14.04 (trusty)
   * many non-gui states also work with older/newer ubuntu and other debian based distros.
   * most gui states work with xenial
   
 * Features to look at:
   * [storage`](storage):
     * setup harddisk storage, features parted, mdadm, crypt, lvm, format, mount, swap, directories, relocate services
   * [network`](network):
     * setup network, calculate network adresses netmasks a.o.
   * [http_proxy](http_proxy):
     * [.server](http_proxy/server.sls): install polipo
     * [.client_use_proxy](http_proxy/client_use_proxy.sls)
     * [.client_no_proxy](http_proxy/client_no_proxy.sls)
     * setup http_proxy, HTTP_PROXY for: apt, profile.d, sudoers.d
   * [unbound](unbound):
     * caching recursive dns resolver
   * [knot](knot):
     * authoritative dnsec capable dns server
   * [console-tools](console-tools):
     * tools for administration
   * [`roles.desktop`](roles/desktop):
     * everything needed from a desktop base installation for developing (ubuntu 16.04)

### How to start:

 * [`/salt-top.example`](salt-top.example): Example states top file
 * [`/pillar-top.example`](pillar-top.example): Example pillar data

 * without a saltmaster:
   * fork/download salt-setup-template and look there for more info

 * with a saltmaster:
   * include this repository as a salt directory and point salt master config to it

### directory layout:

 * `/.*`      : salt states
 * [`/roles/*`](/roles/) : deprecated high level salt states
 * [`/roles/desktop/*`](/roles/desktop/) : used for desktop setups
