## salt-shared - useful Salt states

A collection of saltstack states mostly useful for a desktop setup.

+ Target Platforms:
    + **Arch Linux** \& **Manjaro Linux**

+ To bootstrap a machine from scratch (including a custom storage setup), see:
    + [machine-bootstrap](https://github.com/wuxxin/machine-bootstrap)

### Features

+ Desktop with Applications
    + [Desktop](desktop/manjaro): Manjaro Desktop with curated list of Applications
    + [Development](desktop/manjaro/development.sls) Manjaro Desktop plus Development Tools
        + [Scientific Python](desktop/python): JupyterLab Scientific & Machinelearning Python Stack
        + [Development Languages and Tools](code): base language environments, language server, linter a.o. tools

+ Machine / Hardware / OS / Storage Support
    + [node](node): basic machine setup (hostname, locale, network, storage)
    + [arch](arch): archlinux AUR support for arch and manjaro
    + [kernel](kernel): kernel settings for running big hosts
    + [hardware](hardware): hardware related packages and setup
    + [zfs](zfs): ZFS file system and volume management (scrub, trim, snapshot)
    + [tools](tools): useful set of command line tools
    + [systemd](systemd): cgroup, CPU, CPUSET, I/O delegation, accounting limits, journald, resolved
    + [systemd nspawn](systemd/nspawn): lightweight machine container manager

+ Mobile, Embedded \& IOT
    + [android](android): android tools (adb,fastboot,heimdall,scrcopy)
    + [Airrohr](embedded/airrohr) Airquality Sensor, setup and integration into homeassistant
    + [OpenWRT/Builder](embedded/openwrt) Build OpenWRT
    + [OpenWRT/Homeassistant device_tracker](embedded/openwrt/homeassistant-device-tracker) wifi device presence to MQTT publish integration

+ Server & Apps
    + [gitops](app/gitops): deploy and update machines from git, with webhook support
    + [backup](app/backup): Modern backup solution using restic and rclone
    + [containers](app/containers): OCI container runtime glue using podman, podman-compose, x11docker
    + [email](app/email): postfix, opendkim, rspamd transactional inbound/outbound email setup
    + [http_frontend](app/http_frontend): https frontend using nginx, acme.sh and easyrsa
    + [oauth2proxy](app/oauth2proxy): OAuth2Proxy for Oauth2/oidc Authentification
    + [ssh](server/ssh): openssh client and server
    + [http_proxy](app/http_proxy):
        + [.server](app/http_proxy/server.sls): trafficserver as caching http_proxy service
        + [.client_use_proxy](app/http_proxy/client_use_proxy.sls)
        + [.client_no_proxy](app/http_proxy/client_no_proxy.sls)
    + [unbound](server/unbound): caching recursive dns resolver
    + [knot](server/knot): authoritative dnsec capable dns server
    + [coturn](server/coturn): STUN and TURN Server
    + [getmail](server/getmail): fetchmail alternative
    + [postgresql](server/postgresql): Postgresql Database
    + [mysql](server/mysql): MariaDB (mysql compatible) Database

+ unfinished, halfbroken, quirky, old and minimum skeleton packages
    + [android/builder](android/builder) Lineage/MicroG Android OS Builder container for building android
    + [android/redroid](android/redroid) Android Emulator (same kernel, GPU accel, docker container)
    + [android/dockdroid](android/dockdroid) Android Emulator (qemu based, but x86-android, GPU accel, docker container)
    + [android/emulator](android/emulator) Android Emulator (qemu based, emulator) container for desktop and headless
    + [homeassistant](app/homeassistant): Home-Assistant Automation via MQTT
    + [android/android-x86](android/android-x86) Android Emulator (qemu based, but x86-android)
    + [android/waydroid](android/waydroid) Android Emulator (same kernel, GPU Accel, LXC container)
    + [OctoPI](embedded/octopi) Builder for Raspberry PI - OctoPrint (a 3D printer web interface) Distribution
    + [lxc](kernel/lxc): lxc leightweight machine virtualization
    + [opennebula](opennebula): cloud infrastructure virtualization for kvm/lxc/firecracker
    + [haproxy](haproxy) , [syncthing](syncthing) ,  [clevis](clevis) , [envoy](envoy)
    + [step-ca](step-ca) , [terraform](terraform) , [golang](golang) , [nodejs](nodejs)
    + [even older states](old)
