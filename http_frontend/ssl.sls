{% from "http_frontend/defaults.jinja" import settings with context %}
include:
  - http_frontend.dirs
  - http_frontend.pki

# order is important: ssl -> nginx -> letsencrypt

# regenerate snakeoil if not existing or cn != settings.domain
generate_snakeoil:
  pkg.installed:
    - name: ssl-cert
  cmd.run:
    - name: make-ssl-cert generate-default-snakeoil --force-overwrite
    - onlyif: |
        test ! -e /etc/ssl/private/ssl-cert-snakeoil.key -o "$(openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -noout -text | grep Subject: | sed -re 's/.*Subject: .*CN=([^,]+).*/\1/')" != "{{ settings.domain }}"
    - require:
      - pkg: generate_snakeoil

# regenerate dhparam if not existing or smaller than 2048 Bit
{{ settings.cert_dir }}/{{ settings.ssl_dhparam }}:
  cmd.run:
    - name: openssl dhparam -outform PEM -out {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} 2048
    - onlyif: if test ! -e {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}; then true; elif test $(stat -L -c %s {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}) -lt 256; then true; else false; fi
    - require:
      - sls: http_frontend.dirs
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - replace: false
    - require:
      - cmd: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}

{% if settings.key|d(false) and settings.cert|d(false) %}
# use static cert/key
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - contents: |
{{ settings.key|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

{{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - contents: |
{{ settings.cert|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

{% else %}
# use snakeoil cert/key
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.copy:
    - source: /etc/ssl/private/ssl-cert-snakeoil.key
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil

{{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}:
  file.copy:
    - source: /etc/ssl/certs/ssl-cert-snakeoil.pem
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil
{% endif %}

# append dhparam to current server cert
{{ settings.cert_dir }}/{{ settings.ssl_full_cert }}:
  cmd.run:
    - name: cat {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }} {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} > {{ settings.cert_dir }}/{{ settings.ssl_full_cert }}; chmod "0640" {{ settings.cert_dir }}/{{ settings.ssl_full_cert }}
    - require:
      - file: {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - replace: false
    - require:
      - cmd: {{ settings.cert_dir }}/{{ settings.ssl_full_cert }}