{% from "redis/defaults.jinja" import settings, profile_defaults with context %}

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


{% for raw_profile in salt['pillar.get']('redis:profile', []) %}
  {% set profile=salt['grains.filter_by']({'default': default_profile},
    grain='default', default= 'default', merge= raw_profile) %}

/etc/default/redis-server
/etc/init.d/redis-server
/etc/logrotate.d/redis-server
/etc/redis/redis.conf
/lib/systemd/system/redis-server.service
/lib/systemd/system/redis-server@.service

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

{% endfor %}
