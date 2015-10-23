{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

{% from "roles/docker/defaults.jinja" import settings as s with context %}

docker_ppa:
  pkgrepo.managed:
    - repo: 'deb https://apt.dockerproject.org/repo ubuntu-trusty {{ "experimental" if s.dev_version else "main" }}'
    - humanname: "Ubuntu docker Repository"
    - file: /etc/apt/sources.list.d/docker-trusty.list
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: pgp.mit.edu
    - require:
      - pkg: ppa_ubuntu_installer
  cmd.run:
    - name: true
    - require:
      - pkgrepo: docker_ppa

{% endif %}
