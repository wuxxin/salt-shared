include:
  - kernel
  - kernel.sysctl.big
  - kernel.limits.big
  - cgroup
  - python
  - systemd.reload

# pin docker to x.y.* release, so we get updates but no major new version
/etc/apt/preferences.d/docker-preferences:
  file.managed:
    - contents: |
        Package: docker-engine
        Pin: version 1.12.*
        Pin-Priority: 900

# add docker options from pillar to etc/default config, add http_proxy if set
/etc/default/docker:
  file.managed:
    - contents: |
        DOCKER_OPTIONS="{{ salt['pillar.get']('docker:options', '') }}"
{%- if salt['pillar.get']('http_proxy', '') != '' %}
  {%- for a in ['http_proxy', 'HTTP_PROXY'] %}
        {{ a }}="{{ salt['pillar.get']('http_proxy') }}"
  {%- endfor %}
{%- endif %}

docker-requisites:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - ca-certificates
    - require:
      - sls: cgroup
      
docker-network:
  network.managed:
    - name: docker0
    - type: bridge
    - enabled: true
    - ports: none
    - proto: static
    - ipaddr: {{ salt['pillar.get']('docker:ip') }}
    - netmask: {{ salt['pillar.get']('docker:netmask') }}
    - stp: off
    - require:
      - pkg: docker-requisites

docker-service:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://docker/docker.service
    - watch_in:
      - cmd: systemd_reload
    - require:
      - pkg: docker

custom-docker-multi-user-symlink:
  file.symlink:
    - name: /etc/systemd/system/multi-user.target.wants/docker.service
    - target: /etc/systemd/system/docker.service

docker:
  pkgrepo.managed:
    - name: 'deb http://apt.dockerproject.org/repo {{ grains.os|lower }}-{{ grains.oscodename }} main'
    - humanname: "Docker Repository"
    - file: /etc/apt/sources.list.d/docker-{{ grains.oscodename }}.list
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: pgp.mit.edu
  pkg.installed:
    - pkgs:
      - docker-engine
    - require:
      - pkgrepo: docker
      - pkg: docker-requisites
      - file: /etc/apt/preferences.d/docker-preferences
      - network: docker-network
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
