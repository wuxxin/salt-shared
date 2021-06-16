{% from "containers/defaults.jinja" import settings with context %}

include:
  - kernel.server

{% set baseurl =
  'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_'+
  grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

/etc/containers:
  file:
    - directory

{% for dirname in [
    settings.podman.system.config_basepath,
    settings.podman.system.workdir_basepath,
    settings.podman.system.build_basepath,
    settings.compose.system.config_basepath,
    settings.compose.system.workdir_basepath,
    settings.compose.system.build_basepath] %}
{{ dirname }}:
  file:
    - directory
    - mode: "0750"
{% endfor %}

/etc/containers/containers.conf:
  cmd.run:
    - name: rm /etc/containers/containers.conf && cp /usr/share/containers/containers.conf /etc/containers/containers.conf
    - onlyif: test -L /etc/containers/containers.conf
    - require:
      - file: /etc/containers
  file.serialize:
    - dataset: {{ settings.config.containers }}
    - formatter: toml
    - merge_if_exists: True
    - require:
      - cmd: /etc/containers/containers.conf

/etc/containers/storage.conf:
  file.serialize:
    - dataset: {{ settings.config.storage }}
    - formatter: toml
    - merge_if_exists: True
    - require:
      - file: /etc/containers

/etc/containers/mounts.conf:
  file.managed:
    - contents: |
        # Global Mounts: The format of the mounts.conf is the volume format /SRC:/DEST
  {%- if settings.config.mounts.mounts|d([]) %}
    {%- for mount in settings.config.mounts.mounts %}
        {{ mount }}
    {%- endfor %}
  {%- endif %}
    - require:
      - file: /etc/containers

/etc/containers/policy.json:
  file.serialize:
    - dataset: {{ settings.config.policy }}
    - formatter: json
    - require:
      - file: /etc/containers

podman:
  pkgrepo.managed:
    - name: deb {{ baseurl }}/ /
    - key_url: {{ baseurl }}/Release.key
    - file: /etc/apt/sources.list.d/podman_ppa.list
    - require_in:
      - pkg: podman
  pkg.installed:
    - pkgs:
      - uidmap
      - criu
      - crun
      - cri-o-runc
      - cri-tools
      - containernetworking-plugins
      - slirp4netns
      - fuse-overlayfs
      - skopeo
      - buildah
      - podman

# fork of https://github.com/containers/podman-compose + patches
# see https://github.com/wuxxin/podman-compose
podman_compose.py:
  file.managed:
    - source: salt://containers/tools/podman_compose.py
    - name: /usr/local/bin/podman-compose
    - mode: "0755"

{% endif %}
