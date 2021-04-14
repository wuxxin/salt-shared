## salt-shared - useful Salt states

A collection of saltstack states. Most states are working,
some states have a documentation README.md

### What can you do with it

* Target Platform: Ubuntu Focal 20.04 LTS
    * many states also work with older/newer ubuntu/debian based distros

* To bootstrap a machine from scratch (including a custom storage setup), see:
    * [machine-bootstrap](https://github.com/wuxxin/machine-bootstrap)

* Features
    * Machine
        * [node](node): basic machine setup (hostname, locale, network, storage)
        * [kernel](kernel): kernel- image,headers,tools, modifications for running on big hosts
        * [hardware](hardware): hardware setup
        * [gitops](gitops): deploy and update machines from git, with webhook support#
        * [ubuntu](ubuntu): disable or enable ubuntu specifics

    * Admin
        * [tools](tools): command line tools
        * [vcs](vcs): git, git-crypt, git-bridge, mercurial, bzr, subversion
        * [ssh](ssh):
        * [zfs](zfs):
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
        * [oauth2proxy](oauth2proxy): OAuth2Proxy for Oauth2/oidc Authentification

    * Email
        * [email](email): postfix, opendkim, rspamd transactional inbound/outbound email setup
        * [getmail](getmail): fetchmail alternative

    * Android
        * [android](android): tools and android emulator container for desktop and headless emulator

    * Virtual Machines
        * [kvm+qemu](kernel/kvm): qemu/kvm full virtualization
        * [libvirt](libvirt): libvirt virtualization (kvm-qemu and others)
        * [lxc](kernel/lxc): lxc leightweight machine virtualization
        * [systemd nspawn](nspawn): leightweight machine container manager
        * [vagrant](vagrant): vagrant virtual machine manager (libvirt, lxc, a.o.)
        * [opennebula](opennebula): cloud infrastructure virtualization for kvm/lxc/firecracker

    * Container
        * [containers](containers): (OCI) Containers and Container Images Runtime including podman
        * [k3s](k3s): selfcontained, small footprint Kubernetes Distribution

    * Database
        * [postgresql](postgresql): Postgresql Database
        * [mysql](mysql): MariaDB (mysql compatible) Database
        * [redis](redis): Redis (Key/Value Store) Instances
