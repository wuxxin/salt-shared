include:
  - .ppa

{% from "roles/haproxy/defaults.jinja" import template with context %}
{% set haproxy=salt['grains.filter_by']({'none': template.haproxy }, 
  grain='none', default= 'none', merge= pillar.haproxy|d({})) %}

haproxy:
  pkg.installed:
    - require:
      - pkgrepo: haproxy-ppa
  service.present:
    - require:
      - pkg: haproxy
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://roles/haproxy/haproxy.cfg
    - template: jinja
    - context: {{ haproxy }}
    - watch_in:
      - service: haproxy
