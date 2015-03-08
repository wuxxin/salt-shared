{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "roles/docker/defaults.jinja" import settings as s with context %}

{% if s.dev_version == true %}

docker_ppa:
  pkgrepo.managed:
    - ppa: docker-maint/testing
    - file: /etc/apt/sources.list.d/docker-trusty.list
    - require:
      - pkg: ppa_ubuntu_installer

{% else %}

docker_ppa:
  pkgrepo.managed:
    - repo: 'deb http://get.docker.io/ubuntu docker main'
    - humanname: "Ubuntu docker Repository"
    - file: /etc/apt/sources.list.d/docker-trusty.list
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer

{% endif %}

