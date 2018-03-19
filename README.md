## salt-shared - useful Salt states

This is a collection of saltstack states
as a result of me learning saltstack.

It is already in a useful condition,
both quality and style differ from state to state,
most states are working, some are not,
it lacks documentation beside a few README.md.


### What can you do with it

* Target Platform: Ubuntu LTS 16.04 (xenial), LTS 18.04 (bionic)
    * many non-gui states also work with older/newer ubuntu and other debian based distros.
    * most gui states work with xenial
   
* Features to look at:
    * [desktop](desktop):
        * everything wanted for a desktop installation (ubuntu 16.04)
    * [appliance](appliance):
        * base for automatic updates, automatic backup, metric collection and error reporting
    * [storage](storage):
        * setup harddisk storage, features parted, mdadm, crypt, lvm, format, mount, swap, directories, relocate services
    * [network](network):
        * setup network, calculate network adresses netmasks a.o.
    * [http_proxy](http_proxy):
        * [.server](http_proxy/server.sls): install polipo
        * [.client_use_proxy](http_proxy/client_use_proxy.sls)
        * [.client_no_proxy](http_proxy/client_no_proxy.sls)
        * setup http_proxy, HTTP_PROXY for: apt, profile.d, sudoers.d
 
* Other states to look at:
    * [tools](tools): command line tools for administration
    * [hardware](hardware)
    * [kernel](kernel)
    * [libvirt](libvirt)
    * [docker](docker)
    * [lxd](lxd)
    
    * [golang](golang)
    * [python](python)
    * [java](java)
    
    * [unbound](unbound): caching recursive dns resolver
    * [knot](knot): authoritative dnsec capable dns server

    * [lab](lab): Experimental Work

### How to start

 * [`/salt-top.example`](salt-top.example): Example states top file
 * [`/pillar-top.example`](pillar-top.example): Example pillar data
