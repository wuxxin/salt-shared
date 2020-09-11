{% from "http_frontend/defaults.jinja" import settings with context %}
include:
  - http_frontend.dirs
  - http_frontend.pki

# order is important: ssl -> nginx -> letsencrypt

ssl_requisites:
  pkg.installed:
    - pkgs:
      - openssl
      - ssl-cert

# regenerate dhparam if not existing or smaller than 2048 Bit
{{ settings.cert_dir }}/{{ settings.ssl_dhparam }}:
  cmd.run:
    - name: openssl dhparam -outform PEM -out {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} 2048
    - onlyif: if test ! -e {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}; then true; elif test $(stat -L -c %s {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}) -lt 256; then true; else false; fi
    - require:
      - sls: http_frontend.dirs
      - pkg: ssl_requisites
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - replace: false
    - require:
      - cmd: {{ settings.cert_dir }}/{{ settings.ssl_dhparam }}

# regenerate snakeoil if not existing or cn != settings.domain
generate_snakeoil:
  cmd.run:
    - name: make-ssl-cert generate-default-snakeoil --force-overwrite
    - onlyif: |
        test ! -e {{ settings.ssl_snakeoil_key_path }} -o "$(openssl x509 -in {{ settings.ssl_snakeoil_cert_path }} -noout -text | grep Subject: | sed -re 's/.*Subject: .*CN=([^,]+).*/\1/')" != "{{ settings.domain }}"
    - require:
      - pkg: ssl_requisites

generate_invalid:
  cmd.run:
    - name: |
        set -eo pipefail
        HostName="invalid"
        SubjectAltName="DNS:$HostName"
        template="/usr/share/ssl-cert/ssleay.cnf"
        TMPFILE="$(mktemp)" || exit 1
        TMPOUT="$(mktemp)"  || exit 1
        trap "rm -f $TMPFILE $TMPOUT" EXIT
        sed -e s#@HostName@#"$HostName"# -e s#@SubjectAltName@#"$SubjectAltName"# $template > $TMPFILE
        if ! openssl req -config $TMPFILE -new -x509 -days 3650 -nodes -sha256 \
            -out {{ settings.ssl_invalid_cert_path }} \
            -keyout {{ settings.ssl_invalid_key_path }} > $TMPOUT 2>&1
        then
            echo Could not create certificate. Openssl output was: >&2
            cat $TMPOUT >&2
            exit 1
        fi
        chmod 644 {{ settings.ssl_invalid_cert_path }}
        chmod 640 {{ settings.ssl_invalid_key_path }}
        chown root:ssl-cert {{ settings.ssl_invalid_key_path }}
        # append dhparam
        cat {{ settings.ssl_invalid_cert_path }} {{ settings.cert_dir }}/{{ settings.ssl_dhparam }} > {{ settings.ssl_invalid_full_cert_path }}
        chmod 644 {{ settings.ssl_invalid_full_cert_path }}
    - onlyif: test ! -e {{ settings.ssl_invalid_key_path }}
    - require:
      - pkg: ssl_requisites
      - file: { settings.cert_dir }}/{{ settings.ssl_dhparam }}

{{ settings.cert_dir }}/cert-renew-hook.sh:
  file.managed:
    - source: salt://http_frontend/cert-renew-hook.sh
    - mode: "0755"
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - sls: http_frontend.dirs

/etc/sudoers.d/http_frontend_cert_renew_hook:
  file.managed:
    - makedirs: True
    - mode: "0644"
    - contents: |
        {{ settings.user }} ALL=(ALL) NOPASSWD:/usr/bin/systemctl reload-or-restart nginx

{% if settings.key|d(false) and settings.cert|d(false) %}
# use static cert/key
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - contents: |
{{ settings.key|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

  {% for i in [settings.ssl_chain_cert, settings.ssl_cert] %}
{{ settings.cert_dir }}/{{ i }}:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - contents: |
{{ settings.cert|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs
  {% endfor %}

{% else %}
# use snakeoil cert/key
{{ settings.cert_dir }}/{{ settings.ssl_key }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_key_path }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil

  {% for i in [settings.ssl_chain_cert, settings.ssl_cert] %}
{{ settings.cert_dir }}/{{ i }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_cert_path }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil
  {% endfor %}
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
    - group: {{ settings.user }}
    - mode: "0640"
    - replace: false
    - require:
      - cmd: {{ settings.cert_dir }}/{{ settings.ssl_full_cert }}

# copy snakeoil to every virtual host as default, will not get copied if target already existing
{%- for vhost in settings.virtual_hosts %}
  {%- set vhost_domain= vhost.split(' ')|first %}
{{ settings.cert_dir }}/vhost/{{ vhost_domain }}:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - makedirs: true
    - mode: "0750"
{{ settings.cert_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_chain_cert }}:
  file.copy:
    - source: {{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - makedirs: true
    - mode: "0640"
{{ settings.cert_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }}:
  file.copy:
    - source: {{ settings.cert_dir }}/{{ settings.ssl_key }}
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - makedirs: true
    - mode: "0640"
{% endfor %}
