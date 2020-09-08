## salt-shared - useful Salt states

A collection of saltstack states. Most states are working,
some states have a documentation README.md

### What can you do with it

* Target Platforms: Ubuntu Focal 20.04 LTS
    * many states also work with older/newer ubuntu and other debian based distros.
    * To bootstrap a machine from scratch with a custom storage setup, see:
      [machine-bootstrap](https://github.com/wuxxin/machine-bootstrap)

* Features
    * [node](node): basic machine setup (hostname, locale, network, storage)
    * [gitops](gitops): deploy and update machines from git, with webhook support
    * [hardware](hardware): hardware setup
    * [kernel](kernel): kernel- image,headers,tools, modifications for running on big hosts
    * [tools](tools): command line tools
        * [vcs](vcs): git, git-crypt, git-bridge, mercurial, bzr, subversion
    * [python Language Support](python)

    * Desktop
        * [desktop](desktop): everything wanted for a desktop installation

    * Network
        * [http_proxy](http_proxy):
            * [.server](http_proxy/server.sls): trafficserver as internal caching http_proxy server
            * [.client_use_proxy](http_proxy/client_use_proxy.sls)
            * [.client_no_proxy](http_proxy/client_no_proxy.sls)
        * [unbound](unbound): caching recursive dns resolver
        * [knot](knot): authoritative dnsec capable dns server
        * [coturn](coturn): STUN (Session Traversal Utilities for NAT) and TURN (Traversal Using Relays
 around NAT)
        * [wireguard](wireguard): Wireguard VPN
        * [strongswan](strongswan): IPsec VPN
        * [unison](unison): Unison File Sync
        * [syncthing](syncthing): network file syncronisation

    * Web
        * [http_frontend](http_frontend): modern https frontend using nginx, acme.sh and easyrsa

    * Email
        * [email](email): postfix, opendkim, rspamd transactional inbound/outbound email setup
        * [getmail](getmail): fetchmail alternative

    * Virtual Machines
        * [libvirt](libvirt): libvirt, qemu/kvm full virtualization
        * [systemd nspawn](nspawn): leightweight machine virtualization
        * [lxc](lxc): lxc leightweight machine virtualization
        * [vagrant](vagrant): vagrant virtual machine manager for libvirt, lxc, lxd, a.o.

    * Container Management
        * [containers](containers): (OCI) Containers and Container Images Runtime including podman
        * [docker](docker): Legacy Docker Containers and Container Images Runtime
        * [k3s](k3s): small footprint Kubernetes Distribution

    * Database
        * [postgresql](postgresql): Postgresql Database
        * [mysql](mysql): MariaDB (mysql compatible) Database
        * [redis](redis): one or more Redis (Key/Value Store) Instances
