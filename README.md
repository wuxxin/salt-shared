## salt-shared - useful Salt states

A collection of saltstack states.

Quality and style differ from state to state, most states are working,
some states have documentation README.md's.

### What can you do with it

* Target Platforms: Ubuntu Focal 20.04 LTS and 19.10; 19.04; 18.04; debian 10
    * many non-gui states also work with older/newer ubuntu and other debian based distros.
    * To bootstrap a machine with a custom storage setup, see:
      [machine-bootstrap](https://github.com/wuxxin/machine-bootstrap)

* Features to look at:
    * [node](node): basic machine setup (hostname, locale, network, storage)
    * [hardware](hardware): hardware setup
    * [kernel](kernel): kernel- image,headers,tools
    * [tools](tools): command line tools
    * [gitops](gitops): deploy and update machines from git, with webhook support
    * [http_frontend](http_frontend): simple modern https frontend

    * Desktop
        * [desktop](desktop):
          * everything wanted for a desktop installation (mostly 20.04)

    * Network
        * [http_proxy](http_proxy):
            * [.server](http_proxy/server.sls): install trafficserver
            * [.client_use_proxy](http_proxy/client_use_proxy.sls)
            * [.client_no_proxy](http_proxy/client_no_proxy.sls)
        * [unbound](unbound): caching recursive dns resolver
        * [knot](knot): authoritative dnsec capable dns server
        * [syncthing](syncthing): network file syncronisation
        * [strongswan](strongswan): IPsec VPN
        * [wireguard](wireguard): Wireguard VPN

    * Virtual Machines
        * [libvirt](libvirt): libvirt/qemu/kvm setup
        * [docker](docker): docker production installation
        * [lxd](lxd): lxd production installation
        * [vagrant](vagrant): vagrant virtual machine manager
        * [k3s](k3s): small footprint Kubernetes Distribution

    * Language Support
        * [python](python)
        * [java](java)
        * [latex](latex)
        * [vcs](vcs): git, git-crypt, git-bridge, mercurial, bzr, subversion

    * [lab](lab): Experimental Work
    * [old](old): Old States
