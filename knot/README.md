Feature: use more than one knot instance
Pillar Layout: knot:instance: an array of normal knot.conf yaml with some additions:
  id: id of server
  active: true,false
  logging: if empty will use defaults.jinja:log_default
  zone:
    - source: salt source file which gets copied to default file target for zone
