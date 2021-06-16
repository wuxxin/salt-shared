# modern containers using podman

+ uses ppa for podman, crun, buildah, skopeo, fuse-overlayfs
+ source snapshots of podman-compose \& x11docker
+ easy rootless support with user !=''

## containers.lib

+ create a named volume
  + `volume(name, opts=[], driver='local', labels=[], env={}, user='')`

+ get full path of volume
  + `volume_path(volume_name, container_definition, user='')`

+ pull or build an image
  + `image(name, tag='', source='', buildargs={}, builddir= '', user='')`

+ start as systemd service/oneshot by pulling/building and optionally starting container
  + `container(container_definition, user='')`

+ start a systemd service,oneshot by pulling/building and starting a compose structure
  + `compose(compose_definition, user='')`

### configure

+ see `defaults.jinja` for details and comments of `default_container` and `default_compose`
+ container types: "build", "service", "oneshot", "command", "desktop"
+ compose types: "service", "oneshot"
+ computed environment
  + SERVICE_NAME is set to definition.name
  + USER, HOME is set to user and homedir of user if user!=''

### remarks

+ The podman run and podman create commands now feature a --sdnotify option to control the behavior of systemd's sdnotify with containers, enabling improved support for Podman in Type=notify units.

+ Podman with the crun OCI runtime now supports a new option to podman run and podman create, --cgroup-conf, which allows for advanced configuration of cgroups on cgroups v2 systems.

+ Podman can be easily run as a normal user, without requiring a setuid binary. When run without root, Podman containers use user namespaces to set root in the container to the user running Podman. Rootless Podman runs locked-down containers with no privileges that the user running the container does not have. Some of these restrictions can be lifted (via --privileged, for example), but rootless containers will never have more privileges than the user that launched them. If you run Podman as your user and mount in /etc/passwd from the host, you still won't be able to change it, since your user doesn't have permission to do so.
