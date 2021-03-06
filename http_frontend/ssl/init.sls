{% from "http_frontend/defaults.jinja" import settings with context %}

include:
  - http_frontend.dirs
  - http_frontend.pki

ssl_requisites:
  pkg.installed:
    - pkgs:
      - openssl
      - ssl-cert

/usr/local/sbin/create-selfsigned-host-cert.sh:
  file.managed:
    - mode: "0755"
    - source: salt://http_frontend/ssl/create-selfsigned-host-cert.sh

/etc/sudoers.d/http_frontend_cert_renew_hook:
  file.managed:
    - makedirs: True
    - mode: "0644"
    - contents: |
        {{ settings.cert_user }} ALL=(ALL) NOPASSWD:/usr/bin/systemctl reload-or-restart nginx

{{ settings.cert_dir }}/cert-renew-hook.sh:
  file.managed:
    - source: salt://http_frontend/ssl/cert-renew-hook.sh
    - mode: "0755"
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - sls: http_frontend.dirs

# regenerate dhparam if not existing or smaller than 2048 Bit
{{ settings.cert_dir }}/{{ settings.ssl_dhparam }}:
  cmd.run:
    - runas: {{ settings.cert_user }}
    - umask: 027
    - name: openssl dhparam -outform PEM -out {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} 2048
    - onlyif: if test ! -e {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}; then true; elif test $(stat -L -c %s {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}) -lt 256; then true; else false; fi
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
    - runas: {{ settings.cert_user }}
    - name: |
        /usr/local/sbin/create-selfsigned-host-cert.sh \
          -k {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_key) }} \
          -c {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_cert) }} \
          host.invalid
    - onlyif: test ! -e {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_key) }}
    - require:
      - pkg: ssl_requisites
      - file: /usr/local/sbin/create-selfsigned-host-cert.sh

append_dhparam_to_invalid_cert:
  cmd.run:
    - runas: {{ settings.cert_user }}
    - umask: 027
    - name: |
        cat {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_cert) }} \
          {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} >
          {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_full_cert }}
    - onlyif: test ! -e {{ salt['file.join'](settings.cert_dir, settings.ssl_invalid_full_cert) }}
    - require:
      - cmd: generate_invalid_cert
      - file: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}

{% if settings.cert_key|d(false) and settings.cert_crt|d(false) %}
# use static cert/key for base host
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - mode: "0640"
    - contents: |
{{ settings.cert_key|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

  {% for i in [settings.ssl_cert, settings.ssl_chain_cert] %}
{{ settings.cert_dir }}/{{ i }}:
  file.managed:
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - mode: "0640"
    - contents: |
{{ settings.cert_crt|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs
  {% endfor %}

{% else %}
# use snakeoil cert/key for base host
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_key_path }}
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil_cert

  {% for i in [settings.ssl_cert, settings.ssl_chain_cert] %}
{{ settings.cert_dir }}/{{ i }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_cert_path }}
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil_cert
  {% endfor %}
{% endif %}

# append dhparam to current server cert
{{ settings.cert_dir }}/{{ settings.ssl_full_cert }}:
  cmd.run:
    - runas: {{ settings.cert_user }}
    - umask: 027
    - name: |
        cat {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }} \
          {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} >
            {{ settings.cert_dir }}/{{ settings.ssl_full_cert }}
    - require:
      - file: {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}

# generate self signed cert for every virtual host if target cert is not existing
{%- for vhost in settings.virtual_names %}
  {%- set vhost_domain= vhost.split(' ')|first %}
{{ settings.cert_dir }}/vhost/{{ vhost_domain }}:
  file.directory:
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - makedirs: true
    - mode: "0750"
  cmd.run:
    - runas: {{ settings.cert_user }}
    - name: |
        /usr/local/sbin/create-selfsigned-host-cert.sh \
          -k {{ settings.cert_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }} \
          -c {{ settings.cert_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_chain_cert }} \
          {{ vhost|split(' ') }}
    - onlyif: test ! -e {{ settings.cert_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }}
  {% endfor %}
