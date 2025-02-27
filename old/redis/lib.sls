
{% macro mk_redisprofile(entry) %}

/etc/systemd/system/redis-server-{{ entry.name }}.env:
  file:
  {%- if not entry.enabled %}
    - absent
  {%- else %}
    - managed
    - mode: 600
    - source: salt://redis/redis.env
    - defaults:
        settings: {{ entry }}
    - template: jinja
    - require:
      - file: redis-server@.service
  {%- endif %}

redis-server@{{ entry.name }}.service:
  service:
  {%- if entry.enabled|d(True) %}
    - running
    - enable: true
    - watch:
      - file: /etc/systemd/system/redis-server-{{ entry.name }}.env
  {%- else %}
    - dead
    - enable: false
  {%- endif %}
    - require:
      - file: redis-server@.service

{% endmacro %}
