{% from "redis/defaults.jinja" import settings with context %}

redis:
  pkg.installed:
    - pkgs:
      - redis
      - redis-server
  service.running:
    - enable: true
    - require:
      - pkg: redis
    - watch:
      - file: /etc/redis/redis.conf

{% for p,r in [
  ("bind", "bind 127.0.0.1 ::1"),
  ("maxmemory", "maxmemory 128mb"),
  ("maxmemory-policy", "maxmemory-policy volatile-lru"),
  ] %}

redis.conf_{{ p }}:
  file.replace:
    - name: /etc/redis/redis.conf
    - pattern: ^{{ p }}.*
    - repl: {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: redis
    - watch_in:
      - service: redis
    - require_in:
      - service: redis
{% endfor %}
