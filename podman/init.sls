{% from "podman/defaults.jinja" import settings with context %}

include:
  - ubuntu

{# /etc/cni/net.d/87-podman-bridge.conflist #}

{% set baseurl =
  'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_'+
  grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

/etc/containers/libpod.conf:
  file.managed:
    - contents: |
        runtime = "{{ settings.runtime }}"

/etc/containers/mounts.conf:
  file.managed:
    - contents: |
        # Global Mounts: The format of the mounts.conf is the volume format /SRC:/DEST,
        # one mount per line. For example, a mounts.conf with the line
        # /usr/share/secrets:/run/secrets
        # would cause the contents of the /usr/share/secrets directory on the host
        # to be mounted on the /run/secrets directory inside the container.
        # Setting mountpoints allows containers to use the files of the host.
  {%- if settings.mounts %}
    {%- for mount in settings.mounts %}
        {{ mount }}
    {%- endfor %}
  {%- endif %}

/etc/containers/policy.json:
  file.managed:
    - contents: |
        # Manages which registries you trust as a source of container images based on its location.
        # The location is determined by the transport and the registry host of the image.
        # Using this container image docker://docker.io/library/busybox as an example,
        #   docker is the transport and docker.io is the registry host.

/etc/containers/storage.conf:
  file.managed:
    - contents: |
        [storage]
        driver = "{{ settings.storage.driver }}"
        [storage.options]
  {%- if settings.storage.options|d(false) %}
    {%- for key,value in settings.storage.options.items() %}
        {{ key }} = "{{ value }}"
    {%- endfor %}
  {%- endif %}

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
      - cri-o-runc
      - cri-tools
      - skopeo
      - fuse-overlayfs

{% endif %}
