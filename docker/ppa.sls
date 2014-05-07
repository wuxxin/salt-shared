{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}


{% if grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
docker_ppa:
  pkgrepo.managed:
    - repo: 'deb http://get.docker.io/ubuntu docker main'
    - humanname: "Ubuntu docker Repository"
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

