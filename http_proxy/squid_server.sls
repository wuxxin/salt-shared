{% from "http_proxy/defaults.jinja" import settings with context %}

/var/cache/squid:
  file.directory:
    - user: proxy
    - group: proxy

/etc/squid/conf.d/http_proxy.conf:
  file.managed:
    - source: salt://http_proxy/squid_http_proxy.conf
    - template: jinja
    - makedirs: true
    - defaults:
        settings: {{ settings }}

squid:
  pkg.installed:
    - pkgs:
      - squid
      - squid-purge
      - squidclient
    - require:
      - file: /etc/squid/conf.d/http_proxy.conf
      - file: /var/cache/squid
  service.running:
    - enable: True
    - require:
      - pkg: squid
    - watch:
      - file: /etc/squid/conf.d/http_proxy.conf
