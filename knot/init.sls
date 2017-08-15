include:
  - repo.ubuntu


{% if salt['pillar.get']('knot', false) %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("knot-ppa", "cz.nic-labs/knot-dns") }}

knot:
  pkg.installed:
    - names:
      - knot
    - require:
      - pkgrepo: knot-ppa

  {% for server in salt['pillar.get']('knot') %}
    {% if server.active|d(None) == true %}
knot_config_{{ server.id }}:
  file.managed:
    - name: /etc/knot/{{ server.id }}_knot.yml
    - template: jinja
    - file: salt://knot/knot.yml
    - context:
        server: {{ server }}

knot_{{ server.id }}.service:
  file.managed:
    - name: /etc/systemd/knot_{{ server.id }}.service
    - source: salt://knot/knot.service
    - template: jinja
  service.running:
    - require:
      - pkg: knot
    - watch:
        - file: knot_config_{{ server.id }}
        - file: knot_{{ server.id }}.service
    {% endif %}
  {% endfor %}
  
{% endif %}

