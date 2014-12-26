include:
  - .ppa

docker:
  pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc
      - cgroup-bin
      - lxc-docker
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: docker_ppa
{% endif %}
  service.running:
    - enable: true
    - require:
      - pkg: docker

