# Ideas of Software to take a look and maybe integrate

## howto

+ how to send a desktop notification, will get used to send netdata alarms to desktop user

```
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userid/bus" gosu $username bash \
  'notify-send "Notification Titel" "Notification Body with some text" \
  -u critical -i face-worried'
```


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
+ nox
+ pre-commit
  + pre-commit install-hooks
+ sh        # very elegant python shell
+ sarge     # python shell execute with "; &  | && || <>"
+ https://github.com/litl/rauth  # A Python library for OAuth 1.0/a, 2.0, and Ofly

## salt

```yaml
A warning:
  test.configurable_test_state:
    - result: true
    - changes: false
    - warnings: Attention!
```
 salt.states.pip_state.uptodate(name, bin_env=None, user=None, cwd=None, use_vt=False)

https://docs.saltproject.io/en/latest/ref/states/all/salt.states.loop.html
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.kernelpkg.html
https://docs.saltproject.io/en/latest/topics/tutorials/lxc.html#tutorial-lxc-profiles-container
https://docs.saltproject.io/en/latest/topics/cloud/config.html#salt-cloud-config
https://docs.saltproject.io/en/latest/topics/cloud/lxc.html
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.lxc.html#module-salt.states.lxc

https://docs.saltproject.io/en/latest/ref/states/all/salt.states.virtualenv_mod.html#module-salt.states.virtualenv_mod
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.virt.html#module-salt.states.virt
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.ssh_known_hosts.html#module-salt.states.ssh_known_hosts
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.pyenv.html#module-salt.states.pyenv
https://docs.saltproject.io/en/latest/ref/states/all/salt.states.postgres_cluster.html#module-salt.states.postgres_cluster
