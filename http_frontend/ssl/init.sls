{% from "http_frontend/defaults.jinja" import settings with context %}

include:
  - http_frontend.dirs
  - http_frontend.pki


{% macro issue_selfsigned_cert(san_list) %}
# generate a self signed cert for every virtual host
selfsigned-deploy-{{ domain }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - name: |
        /usr/local/sbin/create-selfsigned-host-cert.sh \
          -k {{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }} \
          -c {{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_chain_cert }} \
          {{ vhost|split(' ') }}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }}
    - unless: |
        result="false"
        if test -f "{{ domain_dir }}/fullchain.cer"; then
          if test -f "{{ domain_dir }}/{{ domain }}.cer"; then
            san_list=$(openssl x509 -text -noout -in "{{ domain_dir }}/{{ domain }}.cer" | \
              awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | \
              tr -d "DNS:" | tr "," "\\n" | sort)
            exp_list=$(echo "{{ san_list|join(' ') }}" | tr " " "\\n" | sort)
            if test "$san_list" = "$exp_list"; then result="true"; fi
          fi
        fi
        $result
  {% endfor %}
{% endmacro %}


{% macro issue_casigned_cert(san_list) %}
{# issue new cert, if not already available or SAN list != expected SAN list #}
{% set domain= san_list[0] %}
{% set domain_dir = settings.ssl.base_dir+ '/pki/' + domain %}

local-ca-deploy-{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} /usr/local/sbin/create-host-certificate.sh \
          {{ settings.server_name.split(' \n\t')|join(' ') }}
    - unless: |
        gosu {{ settings.ssl.user }} /usr/local/sbin/create-host-certificate.sh --is-valid-and-listed \
          {{ settings.server_name.split(' \n\t')|join(' ') }}

{{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ settings.ssl.base_dir }}/easyrsa/{{ settings.ssl_chain_cert }} \
          {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} >
            {{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}
{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca }}:
    - require:
      - cmd: local-ca-deploy-{{ domain }}

      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}

{% endmacro %}


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
        {{ settings.ssl.user }} ALL=(ALL) NOPASSWD:/usr/bin/systemctl reload-or-restart nginx

{{ settings.ssl.base_dir }}/ssl-renew-hook.sh:
  file.managed:
    - source: salt://http_frontend/ssl/ssl-renew-hook.sh
    - mode: "0755"
    - template: jinja
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

# regenerate snakeoil if not existing or cn != settings.domain or != valid
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
        /usr/local/sbin/create-selfsigned-host-cert.sh \
          -k {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_key) }} \
          -c {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_cert) }} \
          host.invalid
    - onlyif: test ! -e {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_key) }}
    - require:
      - pkg: ssl_requisites
      - file: /usr/local/sbin/create-selfsigned-host-cert.sh

append_dhparam_to_invalid_cert:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_cert) }} \
          {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} >
          {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_full_cert }}
    - onlyif: test ! -e {{ salt['file.join'](settings.ssl.base_dir, settings.ssl_invalid_full_cert) }}
    - require:
      - cmd: generate_invalid_cert
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}


{% if settings.ssl.host.cert|d(false) and settings.ssl.host.key|d(false) %}
# 1. use static cert/key for base host
{{ settings.ssl.base_dir }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ settings.ssl.host.key|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

  {% for i in [settings.ssl_cert, settings.ssl_chain_cert] %}
{{ settings.ssl.base_dir }}/{{ i }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ settings.ssl.host.cert|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs
  {% endfor %}

{% else %}
  {% if settings.ssl.host.local_ca %}
# 2. use local ca to create host cert
{{ pki_issue_host_cert(settings.server_name.split(' \n\t')) }}

deploy
  gosu {{ settings.ssl.user }} {{ settings.ssl.base_dir }}/ssl-renew-hook.sh \
    "{{ settings.domain }}" \
    "{{ domain_dir }}/{{ domain }}.key" \
    "{{ domain_dir }}/{{ domain }}.cer" \
    "{{ domain_dir }}/fullchain.cer" \
    "{{ domain_dir }}/ca.cer"

  {% else %}
# 3. use snakeoil cert/key for base host
{{ settings.ssl.base_dir }}/{{ settings.ssl_key }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_key_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil_cert

    {% for i in [settings.ssl_cert, settings.ssl_chain_cert] %}
{{ settings.ssl.base_dir }}/{{ i }}:
  file.copy:
    - source: {{ settings.ssl_snakeoil_cert_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - require:
      - sls: http_frontend.dirs
      - cmd: generate_snakeoil_cert
    {% endfor %}
  {% endif %}
{% endif %}

# append dhparam to current server cert
{{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }} \
          {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }} >
            {{ settings.ssl.base_dir }}/{{ settings.ssl_full_cert }}
    - require:
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_chain_cert }}
      - file: {{ settings.ssl.base_dir }}/{{ settings.ssl_dhparam }}

{%- for virtual_host in settings.virtual_names %}
  {%- set vhost_domain= virtual_host.name.split(' \t\n')|first %}

{{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}:
  file.directory:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - makedirs: true
    - mode: "0750"

  {%- if virtual_host.key|d(false) and virtual_host.cert|d(false)) %}
  # just put key/cert into target files
  {%- elif virtual_host.acme.enabled|d(
              settings.ssl.host.acme.enabled) %}
  # if no old acme key/certs are available, generate a selfsigned
  {%- elif settings.host.local_ca %}
  # nomal local ca sign cert
  {%- else %}
  # normal selfsign
  {% endif %}

{%- endfor %}
