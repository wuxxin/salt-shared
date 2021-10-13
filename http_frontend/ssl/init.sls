{% from "http_frontend/defaults.jinja" import settings with context %}
{% from "http_frontend/ssl/lib.sls" import issue_from_file, issue_from_pillar, issue_from_local_ca, issue_self_signed %}

include:
  - http_frontend.dirs
  - http_frontend.pki

ssl_requisites:
  pkg.installed:
    - pkgs:
      - openssl
      - ssl-cert

/usr/local/bin/create-selfsigned-host-cert.sh:
  file.managed:
    - mode: "0755"
    - source: salt://http_frontend/ssl/create-selfsigned-host-cert.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}

/etc/sudoers.d/http_frontend_cert_renew_hook:
  file.managed:
    - makedirs: True
    - mode: "0644"
    - contents: |
        {{ settings.ssl.user }} ALL=(ALL) NOPASSWD:/usr/bin/systemctl reload-or-restart nginx

{{ settings.ssl.base_dir }}/ssl-renew-hook.sh:
  file.managed:
    - source: salt://http_frontend/ssl/ssl-renew-hook.sh
    - mode: "0755"
    - template: jinja
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - defaults:
        settings: {{ settings }}
    - require:
      - sls: http_frontend.dirs

# regenerate dhparam if not existing or smaller than 2048 Bit
{{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: openssl dhparam -outform PEM -out {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} 2048
    - onlyif: if test ! -e {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}; then true; elif test $(stat -L -c %s {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}) -lt 256; then true; else false; fi
    - require:
      - sls: http_frontend.dirs
      - pkg: ssl_requisites

# regenerate snakeoil if not existing or cn != settings.domain
generate_snakeoil_cert:
  cmd.run:
    - name: make-ssl-cert generate-default-snakeoil --force-overwrite
    - onlyif: |
        test ! -e {{ settings.ssl_snakeoil_key_path }} -o \
        "$(openssl x509 -in {{ settings.ssl_snakeoil_cert_path }} -noout -text | \
        grep Subject: | sed -re 's/.*Subject: .*CN=([^,]+).*/\1/')" != "{{ settings.domain }}"
    - require:
      - pkg: ssl_requisites

# generate invalid cert if not existing, append dhparam to it
generate_invalid_cert:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - name: |
        /usr/local/bin/create-selfsigned-host-cert.sh \
          -k {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_key) }} \
          -c {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_cert) }} \
          host.invalid
    - onlyif: test ! -e {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_key) }}
    - require:
      - pkg: ssl_requisites
      - file: /usr/local/bin/create-selfsigned-host-cert.sh

append_dhparam_to_invalid_cert:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_cert) }} \
          {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} \
          > {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_full_cert) }}
    - onlyif: test ! -e {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_full_cert) }}
    - require:
      - cmd: generate_invalid_cert
      - cmd: {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}

# symlinks to host domain
{% for i in [settings.ssl_key, settings.ssl_cert, settings.ssl_chain_cert] %}
symlink_{{ i }}:
  file.symlink:
    - name: {{ settings.ssl.base_dir }}/{{ i }}
    - target: {{ settings.ssl.base_dir }}/vhost/{{ settings.domain }}/{{ i }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
{% endfor %}

# host domain
{{ settings.ssl.base_dir }}/vhost/{{ settings.domain }}:
  file.directory:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - makedirs: true
    - mode: "0750"

{% if settings.ssl.cert|d(false) and settings.ssl.key|d(false) %}
# 1. use static cert/key for host domain cert
{{ issue_from_pillar(settings.server_name.split(' \n\t'),
  settings.ssl.key, settings.ssl.cert) }}
{% else %}
  {% if settings.ssl.local_ca %}
# 2. use local ca to create host domain cert
{{ issue_from_local_ca(settings.server_name.split(' \n\t')) }}
  {% else %}
# 3. use snakeoil cert/key for host domain cert, maybe acme will overwrite it later
{{ issue_from_file(settings.server_name.split(' \n\t'),
  settings.ssl_snakeoil_key_path,
  settings.ssl_snakeoil_cert_path,
  settings.ssl_snakeoil_cert_path, overwrite=false) }}
  {% endif %}
{% endif %}

# append dhparam to current host cert
{{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }} \
          {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} \
          > {{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}
    - require:
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }}
      - cmd: {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}

# virtual domains
{%- for virtual_host in settings.virtual_names %}
  {%- set vhost_san_list= virtual_host.name.split(' \t\n') %}
  {%- set vhost_domain= vhost_san_list|first %}

{{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}:
  file.directory:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - makedirs: true
    - mode: "0750"

  {%- if (virtual_host.key|d(false) and virtual_host.cert|d(false)) %}
# if pillar data is configured, put key/cert into target files
{{ issue_from_pillar(vhost_san_list, virtual_host.key, virtual_host.cert) }}

  {%- elif settings.ssl.acme.enabled and
      virtual_host.acme.enabled|d(settings.ssl.acme.enabled) %}
# if acme enabled, but no old acme key/certs are available for virtual domain, use snakeoil host cert
{{ issue_from_file(vhost_san_list, settings.ssl_snakeoil_key_path,
    settings.ssl_snakeoil_cert_path, settings.ssl_snakeoil_cert_path, overwrite=false) }}

  {%- elif settings.host.local_ca %}
# no pillar data, no acme, but local_ca enabled, create a local ca signed cert
{{ issue_from_local_ca(vhost_san_list) }}

  {%- else %}
# last resort, create a selfsigned certificate
{{ issue_self_signed(vhost_san_list) }}
  {%- endif %}

{%- endfor %}
