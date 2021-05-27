{% from "redis/defaults.jinja" import settings with context %}

/etc/redis/redis.conf:
  file.managed:
    - source: salt://redis/redis.conf
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - makedirs: true
    - watch_in:
      - service: redis

redis:
  pkg.installed:
    - pkgs:
      - redis
      - redis-server
  service:
{%- if settings.enabled %}
    - running
    - enable: true
{%- else %}
    - dead
    - enable: false
{%- endif %}
    - require:
      - pkg: redis

redis-server@.service:
  file.managed:
    - name: /etc/systemd/system/redis-server@.service
    - source: salt://redis/redis-server@.service
    - require:
      - pkg: redis
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: redis-server@.service
