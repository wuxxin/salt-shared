# modern containers for Ubuntu/Debian using podman and containerd

+ uses ppa for podman, crun, buildah, skopeo, fuse-overlayfs
+ uses snapshotted versions of podman-compose, x11docker
+ uses github download for containerd and cri_containerd_cni


## Containerd

+ include: containers.containerd

## Podman

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

+ desktop example
```yaml
desktop:
  template: host
  options:
    - "--webcam"
environment:
  NO_PULSE_AUDIO: "false"
```

+ command = make a "oneshot" /usr/local/bin , ~/.local/bin script
+ desktop = install desktop files to call as a desktop application via x11docker
{% macro write_desktop(entry, user='') %}
{# write desktop environment files (either for everyone or for one user) #}
{#
/usr/local
~/.local
/share/applications/android-{{ name }}.desktop:
/usr/local
~/.local
/bin/android-{{ name }}.sh:
#}
{% endmacro %}

desktop:
  # template: group of options passed to x11docker:  ['default', 'host']
  template: default
  # options: list of string for additional options for x11docker
  options: []
  # entry: desktop entry is used for .desktop file
  entry: {}
  # type: Application
  # name: Android-Emulator
  # comment: Android Emulator Desktop Version
  # exec: env LANG=de_DE.UTF-8 android-emulator.sh
  # terminal: "true"
  # icon: applications-internet
  # categories: Network;
  # keywords: android;emulator;
