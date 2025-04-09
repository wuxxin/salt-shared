{% from "docker/defaults.jinja" import settings with context %}
{% set pkgname= "docker-ce" if settings.origin == "upstream" else "docker.io" %}

include:
  - kernel.server
  - code.python

{# pin docker to x.y.* release, if requested #}
/etc/apt/preferences.d/docker-preferences:
{% if settings.version|d("*") in ["*", "", None] %}
  file:
    - absent
{% else %}
  file.managed:
    - contents: |
        Package: {{ pkgname }}
        Pin: version {{ settings.version }}
        Pin-Priority: 900
{% endif %}

{# set docker defaults, add http_proxy if set #}
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
      - sls: kernel.server

{# install docker network #}
{% if grains['osrelease_info'][0]|int <= 18 %}
docker-network:
  file.managed:
    - name: /etc/network/interfaces.d/80-docker-bridge.cfg
    - contents: |
        auto docker0
        iface docker0 inet static
            address {{ settings.ipv4_cidr|regex_replace ('([^/]+)/.+', '\\1') }}
            netmask {{ salt['network.convert_cidr'](settings.ipv4_cidr)['netmask'] }}
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
              addresses: [{{ settings.ipv4_cidr }}]
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


{# select origin repo for docker #}
{%- if settings.origin == "custom" %}
  {%- set patch_list= ['overlay2-on-zfs.patch', 'overlayfs-in-userns.patch'] %}
  {%- set patch_dir='/usr/local/src/docker-custom-patches' %}
  {%- set patches_string= patch_dir+ '/'+ patch_list|join(' '+ patch_dir+ '/') %}
  {%- set custom_archive= '/usr/local/lib/docker-custom-archive' %}

  {% for p in patch_list %}
add-patch-{{ p }}:
  file.managed:
    - source: salt://docker/{{ p }}
    - name: {{ patch_dir }}/{{ p }}
    - makedirs: true
    - require_in:
      - cmd: docker-custom-build
  {% endfor %}

docker-custom-build:
  pkg.installed:
    - pkgs:
      - cowbuilder
      - ubuntu-dev-tools
  file.managed:
    - source: salt://docker/build-custom-docker.sh
    - name: /usr/local/sbin/build-custom-docker.sh
    - mode: "755"
  cmd.run:
    - name: /usr/local/sbin/build-custom-docker.sh {{ custom_archive }} "overlayzfs" {{ patches_string }}
    - require:
      - pkg: docker-custom-build
      - file: docker-custom-build

docker-custom-repo:
  pkgrepo.managed:
    - name: 'deb [ trusted=yes ] file:{{ custom_archive }} ./'
    - file: /etc/apt/sources.list.d/local-docker-custom.list
    - require_in:
      - pkg: docker
    - require:
      - cmd: docker-custom-build

docker-upstream-repo:
  file.absent:
    - name: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list

{%- elif settings.origin == "upstream" %}
docker-custom-repo:
  file.absent:
    - name: /etc/apt/sources.list.d/local-docker-custom.list

docker-upstream-repo:
  pkgrepo.managed:
    - name: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains.oscodename }} {{ settings.upstream_flavor }}'
    - humanname: "Docker Repository"
    - file: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require_in:
      - pkg: docker

{%- else %}
docker-custom-repo:
  file.absent:
    - name: /etc/apt/sources.list.d/local-docker-custom.list
docker-upstream-repo:
  file.absent:
    - name: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list
{%- endif %}


{# install docker #}
docker:
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
{%- if grains['osrelease_info'][0]|int <= 18 %}
      - pip: docker-compose
{%- else %}
      - pkg: docker-compose
{%- endif %}
      - file: /etc/default/docker
      - file: docker-service
    - watch:
      - file: /etc/default/docker
      - file: docker-service


docker-service:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://docker/docker.service
    - require:
      - pkg: docker
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: docker-service

custom-docker-multi-user-symlink:
  file.symlink:
    - name: /etc/systemd/system/multi-user.target.wants/docker.service
    - target: /etc/systemd/system/docker.service


{# install docker-compose #}
{%- if grains['osrelease_info'][0]|int < 18 or grains['osrelease'] == '18.04' %}
{# the first python3 version of docker-compose was released with 18.10 #}
docker-compose-req:
  pkg.installed:
    - pkgs:
      - python3-cached-property
      - python3-distutils
      - python3-docker
      - python3-dockerpty
      - python3-docopt
      - python3-jsonschema
      - python3-requests
      - python3-six
      - python3-texttable
      - python3-websocket
      - python3-yaml
{% from 'python/lib.sls' import pip_install %}
{{ pip_install('docker-compose', require= 'pkg: docker-compose-req') }}

{%- else %}
docker-compose:
  pkg.installed:
    - pkgs:
      - docker-compose
{%- endif %}
