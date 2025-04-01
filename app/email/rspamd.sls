{% from server/redis/library.sls import mk_redisprofile with context %}
include:
  - redis.server

rspamd:
  pkgrepo.managed:
    - name: deb [arch=amd64] http://rspamd.com/apt-stable/ {{ grains['oscodename'] }} main
    - key_url: https://rspamd.com/apt-stable/gpg.key
    - file: /etc/apt/sources.list.d/rpspamd.list
    - require_in:
      - pkg: rspamd
  pkg.installed:
    - name: rspamd
  service.running:
    - enable: true
    - require:
      - service: redis-server@rspamd-storage.service
      - service: redis-server@rspamd-volatile.service

{% load_yaml as profiles %}
- name: rspamd-storage
  user: rspamd
  memory: 400mb
  policy: volatile-ttl
  working_dir: /var/lib/rspamd/redis-i%
  # socket: /run/redis-i%/redis-storage.sock

- name: rspamd-volatile
  user: rspamd
  memory: 250mb
  policy: allkeys-lfu
  working_dir: /var/lib/rspamd/redis-i%
  # socket: /run/redis-i%/redis-storage.sock
{% endload %}

{% for p in profiles %}
{{ mk_redisprofile(p) }}
{% endfor %}
