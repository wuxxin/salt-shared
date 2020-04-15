{% from "http_proxy/defaults.jinja" import settings with context %}

include:
  - http_proxy.squid_absent

trafficserver:
  pkg.installed:
    - pkgs:
      - trafficserver
  service.running:
    - enable: True
    - require:
      - pkg: trafficserver
      - file: {{ settings.cache_dir }}
    - watch:
      
{{ settings.cache_dir }}:
  file.directory:
    - user: trafficserver
    - group: trafficserver
    - makedirs: true
    - require:
      - pkg: trafficserver

{#
# 1 to 4 weeks lifetime
# throttle to 10K connections
# use ats as caching proxy
# how much memory 'proxy.config.cache.ram_cache.size INT', ''
#}
{% set config_list= [
  ('proxy.config.http.server_ports STRING', settings.listen_port),
  ('proxy.config.http.cache.heuristic_min_lifetime INT', '604800'),
  ('proxy.config.http.cache.heuristic_max_lifetime INT', '2419200'),
  ('proxy.config.net.connections_throttle INT', '10000'),
  ('proxy.config.url_remap.remap_required INT' , '0'),
] %}

{% for item,value in config_list %}
ATS_{{ item }}:
  file.replace:
    - name: /etc/trafficserver/records.config
    - pattern: "^CONFIG {{ item }}.+"
    - repl: CONFIG {{ item }} {{ value }}
    - append_if_not_found: true
    - watch_in:
      - service: trafficserver
{% endfor %}

{% set ip_list=[settings.listen_ip,] if settings.listen_ip is string else settings.listen_ip %}
trafficserver_listen_ip:
  file.replace:
    - name: /etc/trafficserver/records.config
    - pattern: "^LOCAL proxy.local.incoming_ip_to_bind STRING .+"
    - repl: LOCAL proxy.local.incoming_ip_to_bind STRING {% for ip in ip_list %}{{ ip }} {% endfor %}
    - append_if_not_found: true
    - require:
      - pkg: trafficserver
    - watch_in:
      - service: trafficserver

/etc/trafficserver/storage.config:
  file.replace:
    - pattern: "^/[^ ]+ [0-9]+M"
    - repl: {{ settings.cache_dir }} {{ settings.cache_size_mb }}M
    - append_if_not_found: true
    - require:
      - pkg: trafficserver
    - watch_in:
      - service: trafficserver
