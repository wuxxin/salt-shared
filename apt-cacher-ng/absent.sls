apt-cacher-ng:
  pkg:
    - absent
  service:
    - dead
    - require:
      - pkg: apt-cacher-ng
