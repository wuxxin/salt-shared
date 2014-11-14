include:
  .ppa

docker-dependencies:
   pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc
      - cgroup-bin

lxc-docker:
  pkg.latest:
    - require:
      - pkg: docker-dependencies
      - pkgrepo: docker_ppa

docker:
  service.running
    - require:
      - pkg: lxc-docker

