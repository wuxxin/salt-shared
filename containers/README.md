# modern containers for Ubuntu/Debian using podman

+ uses ppa for podman, crun, buildah, skopeo, fuse-overlayfs
+ uses downloaded snapshots of podman-compose, x11docker from source

### Functions

+ create a named volume
  + volume(name, opts=[], driver='local', labels=[], env={}, user='')
+ pull or build an image
  + image(name, tag='', source: '', buildargs= {}, builddir= '', user='')
+ start as systemd service/oneshot by pulling/building and optionally starting container
  + container(definition, user='')
+ start a systemd service,oneshot by pulling/building and starting a compose structure
  + compose(definition, user='')

### Definition

+ container_definition
  + type: "build", "service", "oneshot"
    + build   = build or pull image only, will not generate a systemd service
    + service = make and start command as a systemd service
    + oneshot = make a systemd oneshot execute script
+ compose_definition
  + type: "service", "oneshot"
+ user != '': execute as user using rootless podman
+ for details and comments of options see default_container and default_compose in defaults.jinja


### remarks

+ The podman run and podman create commands now feature a --sdnotify option to control the behavior of systemd's sdnotify with containers, enabling improved support for Podman in Type=notify units.

+ Podman with the crun OCI runtime now supports a new option to podman run and podman create, --cgroup-conf, which allows for advanced configuration of cgroups on cgroups v2 systems.

+ Podman can be easily run as a normal user, without requiring a setuid binary. When run without root, Podman containers use user namespaces to set root in the container to the user running Podman. Rootless Podman runs locked-down containers with no privileges that the user running the container does not have. Some of these restrictions can be lifted (via --privileged, for example), but rootless containers will never have more privileges than the user that launched them. If you run Podman as your user and mount in /etc/passwd from the host, you still won't be able to change it, since your user doesn't have permission to do so.

+ remote  != '': use url to connect to podman (implies podman --remote flag)
+ CONTAINER_HOST is of the format <schema>://[<user[:<password>]@]<host>[:<port>][<path>]
