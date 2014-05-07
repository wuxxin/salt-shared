include:
  - .ppa

knot:
  pkg.installed:
    - require:
      - pkgrepo: knot-ppa
  service.present:
    - require:
      - pkg: knot

unbound:
  pkg:
    - installed
  service.present:
    - require:
      - pkg: unbound
