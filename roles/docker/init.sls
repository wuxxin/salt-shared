include:
  - .ppa
  - .grub

{% if salt['pillar.get']('docker:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('docker:custom_storage')) }}
{% endif %}

{% from "roles/docker/defaults.jinja" import settings as s with context %}

docker:
  pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc
      - cgroup-bin
{% if s.dev_version == true %}
      - docker.io
{% else %}
      - lxc-docker
{% endif %}
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkgrepo: docker_ppa
{% endif %}

  file.managed:
    - name: /etc/default/docker
    - template: jinja
    - source: salt://roles/docker/files/docker
    - context:
      docker: {{ pillar.docker|d({}) }}

  service.running:
    - enable: true
    - require:
      - pkg: docker
      - sls: roles.docker.grub
    - watch:
      - file: docker

{% if s.dev_version == true %}
install_latest_dev_docker:
  file.managed:
    - name: /usr/bin/docker
    - source: https://master.dockerproject.com/linux/amd64/docker-1.5.0-dev
    - source_hash: "sha256=676883d7b168219ee805e037ac8cdc139089840f2d1728ca90fce97907efd2df"
    - watch_in:
      - service: docker
{% endif %}

