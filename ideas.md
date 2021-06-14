# Ideas of Software to integrate

## unsorted

+ https://qgis.org/ubuntu/dists/
  + https://qgis.org/debian/
+ sysdig: pkg.installed
+ minidlna: pkg.installed

## tools

+ https://mosh.org/
Mosh is a replacement for interactive SSH terminals. It's more robust and responsive, especially over Wi-Fi, cellular, and long-distance links.

+ https://github.com/alacritty/alacritty
Alacritty is a modern terminal emulator that comes with sensible defaults, but allows for extensive configuration.

+ https://github.com/schollz/croc
croc is a tool that allows any two computers to simply and securely transfer files and folders.

+ https://github.com/jarun/nnn
nnn (n³) is a full-featured terminal file manager. It's tiny and nearly 0-config with an incredible speed.

## routing
+ FRR https://frrouting.org/ , fork of quaqua and configured BGP EVPN extensions for VXLAN networks

## virtualization

+ KATA containers
  + http://download.opensuse.org/repositories/home:/katacontainers
  + https://virtio-fs.gitlab.io/howto-qemu.html
  + requisites
    + kernel 5.4+
    + QEMU 5.0+ (included in kata-containers 1.9+)
    + kata-containers 1.9+
    + libvirt 6.2+ if libvirt support is needed
  + ppa baseurl
    + 'http://download.opensuse.org/repositories/home:/katacontainers:/releases:/' ~
      grains['cpuarch'] ~ ':/' ~ master ~ '/xUbuntu_' ~ grains['osrelease']

## python
+ sh        # very elegant python shell
+ sarge     # python shell execute with "; &  | && || <>"
+ https://github.com/litl/rauth  # A Python library for OAuth 1.0/a, 2.0, and Ofly
