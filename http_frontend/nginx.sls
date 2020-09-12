{% from "http_frontend/defaults.jinja" import settings with context %}
include:
  - http_frontend.dirs
  - http_frontend.pki
  - http_frontend.ssl

create_http_frontend_maintenance_target_dir:
  file.directory:
    - name: {{ salt['file.dirname'](settings.maintenance_target) }}
    - makedirs: true

/etc/nginx/proxy_params:
  file.managed:
    - makedirs: true
    - contents: |
        # general proxy header settings
        proxy_pass_request_headers on;  # default on, pass header downstream
        # set both Real-IP and Forwarded-For, we dont trust client headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;

/etc/nginx/uwsgi_params:
  file.managed:
    - makedirs: true
    - contents: |
        # general uwsgi param settings
        uwsgi_param  Host               $server_name;
        uwsgi_param  QUERY_STRING       $query_string;
        uwsgi_param  REQUEST_METHOD     $request_method;
        uwsgi_param  CONTENT_TYPE       $content_type;
        uwsgi_param  CONTENT_LENGTH     $content_length;
        uwsgi_param  REQUEST_URI        $request_uri;
        uwsgi_param  PATH_INFO          $document_uri;
        uwsgi_param  DOCUMENT_ROOT      $document_root;
        uwsgi_param  SERVER_PROTOCOL    $server_protocol;
        uwsgi_param  REQUEST_SCHEME     $scheme;
        uwsgi_param  HTTPS              $https if_not_empty;
        uwsgi_param  REMOTE_ADDR        $remote_addr;
        uwsgi_param  REMOTE_PORT        $remote_port;
        # XXX overwrite server_port for uwsgi because we are behind ALPN-Stream Switch
        uwsgi_param  SERVER_PORT        {{ settings.https_port }};
        uwsgi_param  SERVER_NAME        $server_name;
        uwsgi_buffers 8 64k;            # Default: 8 4k|8k; 2nd parameter defines max streaming chunk


/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://http_frontend/nginx.conf
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
{# xenial 1.10, bionic 1.14, eoan 1.16, focal, groovy 1.17.10, ppa (2020-05) 1.17.3 #}
{% from "ubuntu/init.sls" import apt_add_repository %}
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
      - file: {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}
      - file: create_http_frontend_maintenance_target_dir
      - archive: lua_prometheus_module
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/proxy_params
      - file: /etc/nginx/uwsgi_params
