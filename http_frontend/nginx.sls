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

nginx:
  pkg.installed:
    - pkgs:
      - nginx
      - nginx-extras
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
