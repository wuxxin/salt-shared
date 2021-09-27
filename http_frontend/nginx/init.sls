{% from "http_frontend/defaults.jinja" import settings with context %}
include:
  - http_frontend.dirs
  - http_frontend.pki
  - http_frontend.ssl

{% for p in [settings.maintenance_target, settings.upstream_error_target] %}
create_http_frontend_{{ p }}:
  file.directory:
    - name: {{ salt['file.dirname'](p) }}
    - makedirs: true
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - require_in:
      - service: nginx
{% endfor %}

/etc/nginx/proxy_params:
  file.managed:
    - source: salt://http_frontend/nginx/proxy_params
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - makedirs: true

/etc/nginx/uwsgi_params:
  file.managed:
    - source: salt://http_frontend/nginx/uwsgi_params
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - makedirs: true

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://http_frontend/nginx/nginx.conf
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - makedirs: true
    - require:
      - file: /etc/nginx/proxy_params
      - file: /etc/nginx/uwsgi_params

{% set lua_prometheus = settings.external["nginx_lua_prometheus_tar_gz"] %}
lua_prometheus_module:
  file.managed:
    - name: {{ lua_prometheus.target }}
    - source: {{ lua_prometheus.download }}
    - source_hash: sha256={{ lua_prometheus.hash }}
  archive.extracted:
    - source: {{ lua_prometheus.target }}
    - name: /etc/nginx/lua_prometheus
    - archive_format: tar
    - enforce_toplevel: false
    - overwrite: true
    - clean: true
    - options: --strip-components 1
    - onchanges:
      - file: lua_prometheus_module

/var/cache/nginx:
  file.directory:
    - user: www-data
    - group: www-data

{% if grains['os'] == 'Ubuntu' and grains['osmajorrelease']|int < 20 %}
{# bionic 1.14, eoan 1.16, focal, groovy 1.17.10, ppa (2020-05) 1.17.3 #}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("nginx_ppa", "nginx/mainline", require_in= "pkg: nginx") }}
nginx:
  pkg.installed:
    - pkgs:
      - nginx
{% else %}
nginx:
  pkg.installed:
    - pkgs:
      - nginx-extras
{% endif %}
  service.running:
    - enable: true
    - require:
      - pkg: nginx
      - file: /etc/nginx/nginx.conf
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}
      - archive: lua_prometheus_module
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/proxy_params
      - file: /etc/nginx/uwsgi_params
