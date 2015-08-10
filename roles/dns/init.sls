include:
  - .ppa

knot:
  pkg.installed:
    - require:
      - cmd: knot-ppa
  service.running:
    - require:
      - pkg: knot

unbound:
  pkg:
    - installed
  service.running:
    - require:
      - pkg: unbound
