apt-cacher-ng:
  pkg:
    - removed
  service:
    - dead
    - require:
      - pkg: apt-cacher-ng
