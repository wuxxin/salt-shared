include:
  - .ppa
  - .grub
  - python

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
      - docker-engine
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkgrepo: docker_ppa
{% endif %}

  file.managed:
    - name: /etc/default/docker
    - template: jinja
    - source: salt://roles/docker/files/docker
    - context:
      docker: {{ s|d({}) }}

  service.running:
    - enable: true
    - require:
      - pkg: docker
      - sls: roles.docker.grub
      - pip: docker-compose
    - watch:
      - file: docker

docker-compose:
  pip.installed:
    - require:
      - sls: python
