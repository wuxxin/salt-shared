{% from "containers/defaults.jinja" import settings with context %}

include:
  - ubuntu
  - kernel.server

{% set baseurl =
  'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_'+
  grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

/etc/containers:
  file:
    - directory

{{ settings.container.service_basepath }}:
  file:
    - directory
    - mode: "0750"

{{ settings.compose.workdir_basepath }}:
  file:
    - directory
    - mode: "0750"

/etc/containers/containers.conf:
  cmd.run:
    - name: rm /etc/containers/containers.conf && cp /usr/share/containers/containers.conf /etc/containers/containers.conf
    - onlyif: test -L /etc/containers/containers.conf
    - require:
      - file: /etc/containers
  file.serialize:
    - dataset:
        engine: {{ settings.engine }}
    - formatter: toml
    - merge_if_exists: True
    - require:
      - cmd: /etc/containers/containers.conf

/etc/containers/storage.conf:
  file.serialize:
    - dataset:
        storage: {{ settings.storage }}
    - formatter: toml
    - merge_if_exists: True
    - require:
      - file: /etc/containers

/etc/containers/mounts.conf:
  file.managed:
    - contents: |
        # Global Mounts: The format of the mounts.conf is the volume format /SRC:/DEST
  {%- if settings.mounts|d([]) %}
    {%- for mount in settings.mounts %}
        {{ mount }}
    {%- endfor %}
  {%- endif %}
    - require:
      - file: /etc/containers

/etc/containers/policy.json:
  file.managed:
    - contents: |
{{ settings.policy|indent(8,True) }}
    - require:
      - file: /etc/containers

podman:
  pkgrepo.managed:
    - name: deb {{ baseurl }}/ /
    - key_url: {{ baseurl }}/Release.key
    - file: /etc/apt/sources.list.d/podman_ppa.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: podman
  pkg.installed:
    - pkgs:
      - podman
      - buildah
      - crun
      - slirp4netns
      - cri-o-runc
      - cri-tools
      - skopeo
      - fuse-overlayfs

# snapshot (2020/08/26) from: https://raw.githubusercontent.com/flobz/podman-compose/devel/podman_compose.py
podman_compose.py:
  file.managed:
    - source: salt://containers/podman_compose.py
    - name: /usr/local/bin/podman-compose
    - mode: "0755"

{% endif %}
