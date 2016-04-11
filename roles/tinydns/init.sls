djbdns:
  pkg.installed:
    - pkgs:
      - dbndns
      - daemontools
      - runit

{% for u in ("Gdnscache", "Gdnslog", "Gtinydns", "Gaxfrdns") %}
{{ u }}:
  user.present:
    - shell: /bin/false
    - home: /home/{{ u }}
    - system: True
    - require:
      - pkg: djbdns
    - require_in:
      - file: populate_etc_sv
{% endfor %}

create_etc_sv:
  file.directory:
    - name: /etc/sv

populate_etc_sv:
  file.recurse:
    - name: /etc/sv
    - source: salt://roles/tinydns/sv
    - template: jinja
    - defaults:
        dnscache_ip: {{ salt['network.ip_addrs']()[0] }}
{% if pillar.tinydns_server.cache_dns %}
    - context:
        dnscache_ip: {{ pillar.tinydns_server.cache_dns }}
{% endif %}
    - require:
      - file: create_etc_sv

{% for u in ("dnscache", "tinydns", "axfrdns") %}
/var/log/{{ u }}:
  file.directory:
    - makedirs: True
    - group: adm
    - user: Gdnslog
    - require:
      - user: Gdnslog

/etc/sv/{{ u }}/log/main:
  file.symlink:
    - target: /var/log/{{ u }}
    - require:
      - file: /var/log/{{ u }}
      - file: populate_etc_sv

{% for v in ("", "/log") %}
/etc/sv/{{ u }}{{ v }}/run:
    cmd.run:
     - name: chmod +x /etc/sv/{{ u }}{{ v }}/run
     - unless: test -x /etc/sv/{{ u }}{{ v }}/run
     - require:
       - file: populate_etc_sv
{% endfor %}
{% endfor %}


/etc/sv/tinydns/root/data:
  file.managed:
    - source: {{ "%s" % pillar.tinydns_server.internal_data if pillar.tinydns_server.internal_data else 'salt://roles/tinydns/localhost' }}
    - require:
      - file: populate_etc_sv

compiled_data:
  cmd.run:
    - name: make
    - cwd: /etc/sv/tinydns/root
    - watch:
      - file: /etc/sv/tinydns/root/data
    - watch_in:
      - cmd: dnscache_service
      - cmd: tinydns_service
      - cmd: axfrdns_service

create_seed:
  cmd.run:
    - name: dnscache-conf Gdnscache Gdnslog /tmp/dnscache.$$; mv /tmp/dnscache.$$/seed /etc/sv/dnscache/seed; rm -r /tmp/dnscache.$$
    - unless: test -e /etc/sv/dnscache/seed
    - require:
      - file: populate_etc_sv
      - pkg: djbdns

/etc/sv/axfrdns/tcp:
  file.managed:
    - source: salt://roles/tinydns/axfr_permissions
    - template: jinja
    - context:
      permissions: {{ pillar.tinydns_server.axfr_permissions|d(None) }}
    - require:
      - file: populate_etc_sv

compiled_tcp:
  cmd.run:
    - name: make
    - cwd: /etc/sv/axfrdns
    - watch:
      - file: /etc/sv/axfrdns/tcp
    - watch_in:
      - cmd: axfrdns_service
    - require:
      - cmd: compiled_data

{% if pillar.tinydns_server.axfr_export_cmd|d(false) %}
axfrdns_export:
  cmd.run:
    - name: {{ pillar.tinydns_server.axfr_export_cmd }}
    - watch_in:
      - cmd: axfrdns_service
    - require:
      - file: /etc/sv/axfrdns/tcp
      - cmd: compiled_data
{% endif %}

{% set dnscache_serve_to= salt['network.ip_addrs']() %}
{% set dnscache_follow= [('0.0.127.in-addr.arpa','127.0.0.1')] %}
{% if pillar.tinydns_server.cache_serve_to %}
    {% set dnscache_serve_to= pillar.tinydns_server.cache_serve_to %}
{% endif %}
{% if pillar.tinydns_server.cache_follow %}
    {% set dnscache_follow= pillar.tinydns_server.cache_follow %}
{% endif %}

/etc/sv/dnscache/root/ip:
  file.directory:
    - makedirs: True

{% for n in dnscache_serve_to %}
/etc/sv/dnscache/root/ip/{{ n }}:
  file.touch:
    - require:
      - file: populate_etc_sv
      - file: /etc/sv/dnscache/root/ip
    - require_in:
      - cmd: dnscache_service
    - watch_in:
      - cmd: dnscache_service
{% endfor %}

{% for n,s in dnscache_follow.iteritems() %}
/etc/sv/dnscache/root/servers/{{ n }}:
  file.managed:
    - source: salt://roles/tinydns/dnsfollow
    - template: jinja
    - context:
        ip: {{ "%s" % s if s != '' else '127.0.0.1' }}
    - require:
      - file: populate_etc_sv
    - require_in:
      - cmd: dnscache_service
    - watch_in:
      - cmd: dnscache_service
{% endfor %}

{% macro install_and_start(name) %}
{{ name }}_install:
  cmd.run:
    - name: update-service --add /etc/sv/{{ name }}
    - unless: test -e /etc/service/{{ name }}
    - require:
      - pkg: djbdns
      - file: populate_etc_sv
      - file: /var/log/{{ name }}

{{ name }}_service:
   cmd.run:
    - name: svc -t -u /etc/service/{{ name }}
    - onlyif: test -e /etc/service/{{ name }}
    - require:
      - cmd: {{ name }}_install
{% endmacro %}

{% macro stop_and_remove(name) %}
{{ name }}_service:
   cmd.run:
    - name: svc -d /etc/service/{{ name }}
    - onlyif: test -e /etc/service/{{ name }}

{{ name }}_remove:
  cmd.run:
    - name: update-service --remove /etc/sv/{{ name }}
    - onlyif: test -e /etc/service/{{ name }}
    - require:
      - cmd: {{ name }}_service
{% endmacro %}


{% if salt['pillar.get']('tinydns_server:cache:status', false) == "present" %}
{{ install_and_start("dnscache") }}
{% else %}
{{ stop_and_remove("dnscache") }}
{% endif %}

{% if salt['pillar.get']('tinydns_server:internal:status', false) == "present" %}
{{ install_and_start("tinydns") }}
{{ install_and_start("axfrdns") }}
{% else %}
{{ stop_and_remove("tinydns") }}
{{ stop_and_remove("axfrdns") }}
{% endif %}

{% if pillar.tinydns_server.cache_dns and pillar.tinydns_server.redirect_host_dns %}

{% from "network/lib.sls" import change_dns with context %}
{% set oldconfig = salt['pillar.get']('network:interfaces:eth0', {}) %}
{{ change_dns('eth0', oldconfig, pillar.tinydns_server.cache_dns) }}

{% endif %}
