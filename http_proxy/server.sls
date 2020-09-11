{% from "http_proxy/defaults.jinja" import settings with context %}

trafficserver:
  pkg.installed:
    - pkgs:
      - trafficserver
  service.running:
    - enable: True
    - require:
      - pkg: trafficserver
      - file: {{ settings.cache_dir }}

{{ settings.cache_dir }}:
  file.directory:
    - user: trafficserver
    - group: trafficserver
    - makedirs: true
    - require:
      - pkg: trafficserver

{#
# ubuntu has trafficserver 8.x
# documentation: https://docs.trafficserver.apache.org/en/8.0.x/index.html
# configuration advice see: https://cwiki.apache.org/confluence/display/TS/WebProxyCacheTuning
# listening interfaces
# listening port
# enable caching forward proxy
# no url_remap required to use ts as caching forward proxy
# disable reverse proxy
# cache objects have 1 to 4 weeks lifetime
# limit connections to 1K (default 30K)
# limit idle cpu usage via epoll_wait timeout in ms (default 10)
# limit threads to 4 (default cores*1.5)
# limit hostdb size to 8mb
# main memory used for cache index
#}
{% set ip_list=[settings.listen_ip,] if settings.listen_ip is string else settings.listen_ip %}
{% set config_list= [
  ('LOCAL',  'proxy.local.incoming_ip_to_bind STRING', ip_list|join(' ')),
  ('CONFIG', 'proxy.config.http.server_ports STRING', settings.listen_port),
  ('CONFIG', 'proxy.config.http.cache.http INT', '1'),
  ('CONFIG', 'proxy.config.url_remap.remap_required INT' , '0'),
  ('CONFIG', 'proxy.config.reverse_proxy.enabled INT', '0'),
  ('CONFIG', 'proxy.config.http.cache.heuristic_min_lifetime INT', '604800'),
  ('CONFIG', 'proxy.config.http.cache.heuristic_max_lifetime INT', '2419200'),
  ('CONFIG', 'proxy.config.net.connections_throttle INT', '1000'),
  ('CONFIG', 'proxy.config.net.poll_timeout INT', '250'),
  ('CONFIG', 'proxy.config.exec_thread.autoconfig INT', '0'),
  ('CONFIG', 'proxy.config.exec_thread.limit INT', '4'),
  ('CONFIG', 'proxy.config.hostdb.max_size INT', '8M'),
  ('CONFIG', 'proxy.config.cache.ram_cache.size INT', settings.memory_cache_size_mb|string ~ 'M'),
] %}

{% for section,item,value in config_list %}
ATS_{{ section }}_{{ item }}:
  file.replace:
    - name: /etc/trafficserver/records.config
    - pattern: "^{{ section }} {{ item }}.+"
    - repl: {{ section }} {{ item }} {{ value }}
    - append_if_not_found: true
    - require:
      - pkg: trafficserver
    - watch_in:
      - service: trafficserver
{% endfor %}

/etc/trafficserver/storage.config:
  file.replace:
    - pattern: "^/[^ ]+ [0-9]+M"
    - repl: {{ settings.cache_dir }} {{ settings.cache_size_mb }}M
    - append_if_not_found: true
    - require:
      - pkg: trafficserver
    - watch_in:
      - service: trafficserver
