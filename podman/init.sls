{% from "podman/defaults.jinja" import settings with context %}

include:
  - ubuntu
  - kernel.server

{% set baseurl =
  'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_'+
  grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

/etc/containers/libpod.conf:
  file.managed:
    - contents: |
        runtime = "{{ settings.runtime }}"

{# /etc/cni/net.d/87-podman-bridge.conflist #}

/etc/containers/mounts.conf:
  file.managed:
    - contents: |
        # Global Mounts: The format of the mounts.conf is the volume format /SRC:/DEST
  {%- if settings.mounts|d([]) %}
    {%- for mount in settings.mounts %}
        {{ mount }}
    {%- endfor %}
  {%- endif %}

/etc/containers/policy.json:
  file.managed:
    - contents: |
{{ settings.policy|indent() }}


/etc/containers/storage.conf:
  file.managed:
    - contents: |
        [storage]
  {%- for key,value in settings.storage.items() %}
    {%- if key != 'options' %}
        {{ key }} = "{{ value }}"
    {%- endif %}
  {%- endfor %}
        [storage.options]
  {%- if settings.storage.options|d(false) %}
    {%- for key,value in settings.storage.options.items() %}
      {%- if value is not mapping %}
        {{ key }} = "{{ value }}"
      {%- endif %}
    {%- endfor %}
    {%- for key,value in settings.storage.options.items() %}
      {%- if value is mapping %}
        [storage.options.{{ key }}]
        {%- for subkey,subvalue in value.items() %}
        {{ subkey }} = "{{ subvalue }}"
        {%- endfor %}
      {%- endif %}
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
