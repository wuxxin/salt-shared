{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

{% from "roles/docker/defaults.jinja" import settings as s with context %}

docker_ppa:
  pkgrepo.managed:
    - name: 'deb http://apt.dockerproject.org/repo ubuntu-{{ grains['lsb_distrib_codename'] }} {{ "experimental" if s.dev_version else "main" }}'
    - humanname: "Ubuntu docker Repository"
    - file: /etc/apt/sources.list.d/docker-{{ grains['lsb_distrib_codename'] }}.list
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: pgp.mit.edu
    - require:
      - pkg: ppa_ubuntu_installer

{% endif %}

docker_nop:
  test:
    - nop
