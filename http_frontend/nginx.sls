{% from "http_frontend/defaults.jinja" import settings with context %}
include:
  - http_frontend.dirs
  - http_frontend.ssl
  - http_frontend.pki

{{ salt['file.dirname'](settings.maintenance_target) }}:
  file.directory:
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
        uwsgi_param  SERVER_PORT        443;
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
      - nginx-full
      - nginx-extras
{% endif %}
  service.running:
    - enable: true
    - require:
      - pkg: nginx
      - file: /etc/nginx/nginx.conf
      - file: {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/proxy_params
      - file: /etc/nginx/uwsgi_params
