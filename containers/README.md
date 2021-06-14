# modern containers for Ubuntu/Debian using podman

+ uses ppa for podman, crun, buildah, skopeo, fuse-overlayfs
+ uses source snapshots of podman-compose, x11docker

### Functions

+ create a named volume
  + `volume(name, opts=[], driver='local', labels=[], env={}, user='')`
+ pull or build an image
  + `image(name, tag='', source: '', buildargs= {}, builddir= '', user='')`
+ start as systemd service/oneshot by pulling/building and optionally starting container
  + `container(definition, user='')`
+ start a systemd service,oneshot by pulling/building and starting a compose structure
  + `compose(definition, user='')`

### Definition

for details and comments of options see default_container and default_compose in defaults.jinja

+ user != '': execute as user using rootless podman

+ container_definition
  + type: "build", "service", "oneshot", "command", "desktop"
    + build   = build or pull image only, will not generate a systemd service
    + service = make and start command as a systemd service
    + oneshot = make a systemd oneshot execute script
    + command = create a shell script to call the container from the commandline
    + desktop = create a shell script using x11docker to call the container as a gui application

+ compose_definition
  + type: "service", "oneshot"


### computed values

+ container:
  + env: $SERVICE_NAME will be set to name
  + workdir: will be set to settings.podman.[user_]workdir_basepath+ "/"+ name
  + builddir: will be set to settings.podman.[user_]build_basepath+ "/"+ name
  + servicedir: will be set to /etc/systemd/system or ${HOME}/.config/systemd/user
  + scriptdir: will be set to /usr/local/bin or ${HOME}/.local/bin

+ compose:
  + env: $SERVICE_NAME will be set to name
  + workdir: will be set to settings.compose.[user_]workdir_basepath+ "/"+ name
  + builddir: will be set to settings.compose.[user_]build_basepath+ "/"+ name
  + servicedir: will be set to /etc/systemd/system or ${HOME}/.config/systemd/user


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

objects:
  "x11docker.tar.gz":
    version: 6.9.0
    latest: curl -L -s -o /dev/null -w "%{url_effective}" "https://github.com/mviereck/x11docker/releases/latest" | sed -r "s/.*\/v([^\/]+)$/\1/"
    download: "https://github.com/mviereck/x11docker/archive/refs/tags/v##version##.tar.gz"
    hash: 2206866d289e7f0e0fa710af3a62bd0afb1568f7b5510efcf1c2fd5c4f5082c8
    target: /usr/local/lib/x11docker.tar.gz

x11docker:
  file.managed:
    - source: {{ settings.external['x11docker.tar.gz']['download'] }}
    - hash: sha256={{ settings.external['x11docker.tar.gz']['hash'] }}
    - name: {{ settings.external['x11docker.tar.gz']['target'] }}
  archive.extracted:
    - name: /usr/local/bin
    - source: {{ settings.external['x11docker.tar.gz']['target'] }}
    - archive_format: tar

    - enforce_toplevel: false
    - overwrite: true
    - clean: false
    - onchanges:
      - file: x11docker
      -
