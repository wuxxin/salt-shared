## salt-shared - useful Salt states

A collection of saltstack states. Most states are working,
some states have a documentation README.md

* Target Platform: **Ubuntu Focal 20.04 LTS**
    * many states also work with older/newer ubuntu/debian based distros

* To bootstrap a machine from scratch (including a custom storage setup), see:
    * [machine-bootstrap](https://github.com/wuxxin/machine-bootstrap)

### Features

* Machine / Hardware / Distro
    * [node](node): basic machine setup (hostname, locale, network, storage)
    * [kernel](kernel): kernel- image,headers,tools,modifications for running big hosts
    * [hardware](hardware): hardware related packages and setup
    * [ubuntu](ubuntu): disable or enable ubuntu specifics

* [Desktop](desktop): software for a desktop installation

* Deployment / Admin
    * [gitops](gitops): deploy and update machines from git, with webhook support
    * [tools](tools): useful set of command line tools
    * [vcs](vcs): git, git-crypt, git-bridge, mercurial, bzr, subversion
    * [python Language Support](python)
    * [zfs](zfs): OpenZFS is an advanced file system and volume manager

* Network
    * [http_frontend](http_frontend): https frontend using nginx, acme.sh and easyrsa
    * [oauth2proxy](oauth2proxy): OAuth2Proxy for Oauth2/oidc Authentification
    * [ssh](ssh): openssh client and server
    * [http_proxy](http_proxy):
        * [.server](http_proxy/server.sls): trafficserver as caching http_proxy service
        * [.client_use_proxy](http_proxy/client_use_proxy.sls)
        * [.client_no_proxy](http_proxy/client_no_proxy.sls)
    * [unbound](unbound): caching recursive dns resolver
    * [knot](knot): authoritative dnsec capable dns server
    * [coturn](coturn): STUN and TURN Server
    * [wireguard](wireguard): Wireguard VPN
    * [strongswan](strongswan): IPsec VPN

* Virtual Machines
    * [kvm+qemu](kernel/kvm): qemu/kvm full virtualization
    * [libvirt](libvirt): libvirt virtualization (kvm-qemu and others)
    * [systemd nspawn](systemd/nspawn): leightweight machine container manager
    * [vagrant](vagrant): vagrant virtual machine manager (libvirt, lxc, a.o.)

* Container
    * [containers](containers): OCI container runtime using podman, podman-compose, x11docker
    * [containerd](containerd): Kubernetes OCI container runtime
    * [k3s](k3s): selfcontained, small footprint Kubernetes Distribution

* Database
    * [postgresql](postgresql): Postgresql Database
    * [mysql](mysql): MariaDB (mysql compatible) Database
    * [redis](redis): Redis (Key/Value Store) Instances

* Mailserver
    * [email](email): postfix, opendkim, rspamd transactional inbound/outbound email setup
    * [getmail](getmail): fetchmail alternative

* [Applications](app/) using [containers](containers)
    * [homeassistant](app/homeassistant): Home-Assistant Automation via MQTT
      with mosquitto,zigbee2mqtt,homeassistant,appdaemon and rhasspy

* Android
    * [android](android): android tools (adb,fastboot,aapt,heimdall,scrcopy)
    * [android/emulator](android/emulator) Android Emulator (qemu based) container for desktop and headless
    * [android/builder](android/builder) Lineage Android OS Builder container for building android
    * [android/redroid](android/redroid) GPU accelerated Android on same kernel container

* Embedded
    * [Openwrt/Homeassistant device_tracker](openwrt/homeassistant-device-tracker) wifi device presence to MQTT publish integration
    * [Airrohr](iot/airrohr) Airquality Sensor, setup and integration into homeassistant

* unfinished, halfbroken, quirky or very minimum skeleton packages
    * [backup](backup): Modern backup solution using restic and rclone
    * [lxc](kernel/lxc): lxc leightweight machine virtualization
    * [opennebula](opennebula): cloud infrastructure virtualization for kvm/lxc/firecracker
    * [haproxy](haproxy) , [syncthing](syncthing) ,  [clevis](clevis) , [envoy](envoy)
    * [step-ca](step-ca) , [terraform](terraform) , [golang](golang) , [nodejs](nodejs)
