{% from "redis/defaults.jinja" import settings, profile_defaults with context %}

redis.conf_{{ p }}:
  file.replace:
    - name: /etc/redis/redis.conf
    - pattern: ^{{ p }}.*
    - repl: {{ r }}
    - append_if_not_found: true
    - makedirs: true
    - watch_in:
      - service: redis

redis:
  pkg.installed:
    - pkgs:
      - redis
      - redis-server
  service.running:
    - enable: true
    - require:
      - pkg: redis

/etc/systemd/system/redis-server@.service:
  file.managed:
    - source: salt://redis/redis-server@.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/redis-server@.service

{% for raw_profile in salt['pillar.get']('redis:profile', []) %}
  {% set profile=salt['grains.filter_by']({'default': default_profile},
    grain='default', default= 'default', merge= raw_profile) %}

/etc/systemd/system/redis-server-{{ profile.name }}.env:
  file:
  {%- if not profile.enabled %}
    - absent
  {%- else %}
    - managed
    - mode: 600
    - source: salt://redis/redis.env
    - defaults:
        settings: {{ profile }}
    - template: jinja
    - require:
      - file: /etc/systemd/system/redis-server@.service
  {%- endif %}

{% endfor %}
