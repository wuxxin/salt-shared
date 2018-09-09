{% from "docker/defaults.jinja" import settings as s with context %}
{% set pkgname= "docker-ce" if s.from_upstream|d(false) else "docker.io" %}
  
include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - kernel.cgroup
  - python
  - systemd.reload

{# pin docker to x.y.* release, if requested #}
/etc/apt/preferences.d/docker-preferences:
{% if s.version|d("*") in ["*", "", None] %}
  file:
    - absent
{% else %}
  file.managed:
    - contents: |
        Package: {{ pkgname }}
        Pin: version {{ s.version }}
        Pin-Priority: 900
{% endif %}

# add docker options from pillar to etc/default config, add http_proxy if set
/etc/default/docker:
  file.managed:
    - contents: |
        DOCKER_OPTIONS="{{ settings.options|d('') }}"
{%- if salt['pillar.get']('http_proxy', '') != '' %}
{%- from "http_proxy/defaults.jinja" import default_no_proxy %}
        http_proxy="{{ salt['pillar.get']('http_proxy') }}"
        no_proxy="{{ salt['pillar.get']('no_proxy', default_no_proxy) }}"
{%- endif %}

docker-requisites:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - ca-certificates
      - systemd-docker
    - require:
      - sls: kernel.cgroup

{% if grains['osrelease_info'][0]|int <= 18 %}

docker-network:
  file.managed:
    - name: /etc/network/interfaces.d/80-docker-bridge.cfg
    - contents: |
        auto docker0
        iface docker0 inet static
            address {{ settings.ipaddr }}
            netmask {{ settings.netmask }}
            bridge_ports none
            bridge_stp off
            bridge_maxwait 0

    - require:
      - pkg: docker-requisites
  cmd.run:
    - name: ifup docker0
    - unless: ifquery --read-environment --verbose --state docker0
    - onchanges:
      - file: docker-network

{% else %}
docker-network:
  file.managed:
    - name: /etc/netplan/80-docker0-bridge.yaml
    - contents: |
        network:
          version: 2
          bridges:
            docker0:
              dhcp4: false
              addresses: [{{ settings.ipaddr }}/{{ settings.netmask }}]
              parameters:
                forward-delay: 0
    - require:
      - pkg: docker-requisites
  cmd.run:
    - name: netplan apply
    - onlyif: netplan generate
    - onchanges:
      - file: docker-network
{% endif %}

docker-service:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://docker/docker.service
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - pkg: docker

custom-docker-multi-user-symlink:
  file.symlink:
    - name: /etc/systemd/system/multi-user.target.wants/docker.service
    - target: /etc/systemd/system/docker.service

docker:
{%- if s.from_upstream|d(false) %}
  pkgrepo.managed:
    - name: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains.oscodename }} {{ s.upstream_flavor }}'
    - humanname: "Docker Repository"
    - file: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require_in:
      - pkg: docker
{%- else %}
  file.absent:
    - name: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list
{%- endif %}
  pkg.installed:
    - pkgs:
      - {{ pkgname }}
    - require:
      - pkg: docker-requisites
      - file: /etc/apt/preferences.d/docker-preferences
      - file: docker-network
  service.running:
    - enable: true
    - require:
      - pkg: docker
      - pip: docker-compose
      - file: /etc/default/docker
      - file: docker-service
    - watch:
      - file: /etc/default/docker
      - file: docker-service

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('docker-compose') }}
