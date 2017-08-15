{% from "roles/haproxy/defaults.jinja" import template with context %}
{% set haproxy=salt['grains.filter_by']({'None': template.haproxy }, 
  grain='none', default= 'none', merge= pillar.haproxy) %}

haproxy-update-from-client:
  file.managed:
    - name: /etc/haproxy/{{ haproxy.update.frontend }}/backend-{{ haproxy.update.hostname }}-{{ haproxy.update.backend_port }}.cfg
    - context: {{ haproxy }}
    - source: salt://roles/proxy/server/client-template.jinja
    - makedirs
    - template: jinja
