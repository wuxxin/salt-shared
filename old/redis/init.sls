{% from "redis/defaults.jinja" import profile_defaults with context %}
{% from "redis/lib.sls" import mk_redisprofile %}

include:
  - redis.server

redis-server-nop:
  test.nop:
    - require:
      - sls: redis.server

{% for raw_profile in salt['pillar.get']('redis:profile', []) %}
  {% set entry=salt['grains.filter_by']({'default': profile_defaults},
    grain='default', default= 'default', merge= raw_profile) %}

{{ mk_redisprofile(entry) }}

{% endfor %}
