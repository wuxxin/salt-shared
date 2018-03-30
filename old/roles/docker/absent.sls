
docker:
  pkg.removed:
    - pkgs:
      - lxc-docker*
      - docker.io
      - docker-engine
  pip.removed:
    - name: docker-compose
  service:
    - dead
