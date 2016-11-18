{% from "roles/dns/defaults.jinja" import settings as s with context %}

include:
  - .ppa

{% if s.server is defined %}
knot:
  pkg.installed:
    - names:
      - knot
    - require:
      - cmd: knot-ppa

  {% for server in s.server %}
    {% if server.status|d(None) == "present" %}
knot_{{ server.id }}:
  service.running:
    - require:
      - pkg: knot
    - watch:
        - file: knot_{{ server.id }}
  file.managed:
    - name: /etc/knot/{{ server.id }}_knot.yml
    - template: jinja
    - file: salt://roles/dns/server/knot.yml
    - context:
        server: {{ server }}
    {% endif %}
  {% endfor %}
{% endif %}


{% if s.cache.status|d(None) == "present" %}
unbound:
  pkg.installed:
    - require:
      - cmd: nlnetlabs-ppa
  service.running:
    - require:
      - pkg: unbound
    - watch:
      - file: unbound
      - file: /etc/default/unbound
  file.managed:
    - name: /etc/unbound/unbound.conf.d/unbound.conf
    - source: salt://roles/dns/server/unbound.conf
    - template: jinja
    - context:
        cache: {{ s.cache }}

default_unbound_resolvconf:
  file.replace:
    - name: /etc/default/unbound
    - pattern: |
        ^#?[ \t]*RESOLVCONF=.*
    - repl: |
        RESOLVCONF={{ "true" if s.cache.redirect_host_dns == true else "false" }}
    - require:
      - pkg: unbound

default_unbound_RESOLVCONF_FORWARDERS:
  file.replace:
    - name: /etc/default/unbound
    - pattern: |
        ^#?[ \t]*RESOLVCONF_FORWARDERS=.*
    - repl: |
        RESOLVCONF_FORWARDERS=false
    - require:
      - pkg: unbound


{% endif %}
