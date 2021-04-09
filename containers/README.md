# Podman Containers on Ubuntu/Debian

uses: podman (buildah, crun, skopeo, fuse-overlayfs), podman-compose, x11docker

## Functions

+ volume(name, opts=[], driver='local', labels=[], env={}, user='')
+ image(name, tag='', source: '', buildargs= {}, builddir= '', user='')
+ container(container_definition, user='')
+ compose(compose_definition, user='')

+ user != '': execute as user, use rootless podman

### volume(name, opts=[], driver='local', labels=[], env={}, user='')

+ create a named volume

### image(name, tag='', source: '', buildargs= {}, builddir= '', user='')

+ pull or build an image

### container(container_definition, user='')

+ pull or build a container
+ start a container as systemd service/oneshot
+ create a terminal script, gui start script

+ container_definition
  + type: "build", "service", "oneshot", "command", "desktop"
    + build   = build or pull image only, will not generate a systemd service
    + service = make and start command as a systemd service
    + oneshot = make a systemd oneshot execute script
    + command = make a "oneshot" /usr/local/bin , ~/.local/bin script
    + desktop = install desktop files to call as a desktop application via x11docker

### compose(compose_definition, user='')

+ create, pull or build and start a systemd service of the compose file

+ compose_definition
  + type: "service", "oneshot", "command"

## Customize container

+ see default_container and default_compose in defaults.jinja
+ Examples:
```yaml
desktop:
  template: host
  options:
    - "--webcam"
environment:
  NO_PULSE_AUDIO: "false"
```

### remarks

+ The podman run and podman create commands now support a new mode for the --cgroups option, --cgroups=split. Podman will create two cgroups under the cgroup it was launched in, one for the container and one for Conmon. This mode is useful for running Podman in a systemd unit, as it ensures that all processes are retained in systemd's cgroup hierarchy (#6400).

+ The podman run and podman create commands now feature a --sdnotify option to control the behavior of systemd's sdnotify with containers, enabling improved support for Podman in Type=notify units.

+ Podman with the crun OCI runtime now supports a new option to podman run and podman create, --cgroup-conf, which allows for advanced configuration of cgroups on cgroups v2 systems.

+ Podman can be easily run as a normal user, without requiring a setuid binary. When run without root, Podman containers use user namespaces to set root in the container to the user running Podman. Rootless Podman runs locked-down containers with no privileges that the user running the container does not have. Some of these restrictions can be lifted (via --privileged, for example), but rootless containers will never have more privileges than the user that launched them. If you run Podman as your user and mount in /etc/passwd from the host, you still won't be able to change it, since your user doesn't have permission to do so.

+ remote  != '': use url to connect to podman (implies podman --remote flag)
+ CONTAINER_HOST is of the format <schema>://[<user[:<password>]@]<host>[:<port>][<path>]
