include:
  - http_frontend.dirs
  - http_frontend.nginx

{% from "http_frontend/defaults.jinja" import settings with context %}

{% macro issue_cert(san_list, challenge='alpn', env={}) %}
{# issue new cert, if not already available or SAN list != expected SAN list #}
{% set domain= san_list[0] %}
{% set domain_dir = settings.ssl.base_dir+ '/acme.sh/' + domain %}

acme-issue-cert-{{ domain }}:
  cmd.run:
    - env:
      - LE_WORKING_DIR: "{{ settings.ssl.base_dir }}/acme.sh"
  {%- for k,v in env.items() %}
      - {{ k }}: {{ v }}
  {%- endfor %}
    - cwd: {{ settings.ssl.base_dir }}/acme.sh
    - name: |
        gosu {{ settings.ssl.user }} ./acme.sh --issue --server {{ settings.ssl_acme_service }} \
          {% for i in san_list %}-d {{ i }} {% endfor %} \
  {%- if callenge.startswith('dns_') %}
          --dns {{ challenge }} \
  {%- else %}
          --alpn --tlsport {{ settings.alpn_endpoint_port }} \
  {%- endif %}
          --renew-hook '{{ settings.ssl.base_dir }}/ssl-renew-hook.sh "$Le_Domain" "$CERT_KEY_PATH" "$CERT_PATH" "$CERT_FULLCHAIN_PATH" "$CA_CERT_PATH"'
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
    - require:
      - cmd: acme-register-account
      - service: nginx

{# DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" #}
acme-deploy-{{ domain }}:
  cmd.run:
    - env:
      - LE_WORKING_DIR: "{{ settings.ssl.base_dir }}/acme.sh"
    - cwd: {{ settings.ssl.base_dir }}/acme.sh
    - name: |
        gosu {{ settings.ssl.user }} {{ settings.ssl.base_dir }}/ssl-renew-hook.sh \
          "{{ settings.domain }}" \
          "{{ domain_dir }}/{{ domain }}.key" \
          "{{ domain_dir }}/{{ domain }}.cer" \
          "{{ domain_dir }}/fullchain.cer" \
          "{{ domain_dir }}/ca.cer"
    - onchanges:
      - cmd: acme-issue-cert-{{ domain }}
{% endmacro %}


{{ settings.ssl.base_dir }}/acme.sh:
  file.directory:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0750"
    - require:
      - sls: http_frontend.dirs

acme.sh:
  pkg.installed:
    - pkgs:
      - openssl
      - socat
      - gosu
  file.managed:
    - name: {{ settings.external.acme_sh_tar_gz.target }}
    - source: {{ settings.external.acme_sh_tar_gz.download }}
    - source_hash: sha256={{ settings.external.acme_sh_tar_gz.hash }}
    - require:
      - pkg: acme.sh
  archive.extracted:
    - name: {{ settings.ssl.base_dir }}/acme.sh
    - source: {{ settings.external.acme_sh_tar_gz.target }}
    - archive_format: tar
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - enforce_toplevel: false
    - overwrite: true
    - clean: false
    - options: --strip-components 1
    - onchanges:
      - file: acme.sh
    - require:
      - file: {{ settings.ssl.base_dir }}/acme.sh
      - file: acme.sh

{{ settings.ssl.base_dir }}/acme.sh/acme.sh.env:
  file.managed:
    - mode: "0640"
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - contents: |
        export LE_WORKING_DIR="{{ settings.ssl.base_dir }}/acme.sh"
        alias acme.sh="{{ settings.ssl.base_dir }}/acme.sh/acme.sh"
    - require:
      - file: {{ settings.ssl.base_dir }}/acme.sh


{% if not settings.ssl.acme.enabled %}
{# remove account.conf, to keep other parts from assuming it is enabeld #}
{{ settings.ssl.base_dir }}/acme.sh/account.conf:
  file:
    - absent

{% else %}
{{ settings.ssl.base_dir }}/acme.sh/account.conf:
  file.managed:
    - mode: "0640"
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - contents: |
        #LOG_FILE="{{ settings.ssl.base_dir }}/acme.sh/acme.sh.log"
        #LOG_LEVEL=1
        #AUTO_UPGRADE="1"
        #NO_TIMESTAMP=1
        USER_PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'
        TLSPORT={{ settings.alpn_endpoint_port }}
        DEFAULT_ACME_SERVER={{ acme_service }}
        # Do not check the server certificate, in some devices, the api server's certificate may not be trusted.
        # HTTPS_INSECURE="1"
        # Specifies the path to the CA certificate bundle to verify api server's certificate.
        # CA_BUNDLE='<file>'
        # CA_PATH='<directory>'
    - require:
      - file: {{ settings.ssl.base_dir }}/acme.sh

acme-register-account:
  cmd.run:
    - env:
      - LE_WORKING_DIR: "{{ settings.ssl.base_dir }}/acme.sh"
    - cwd: {{ settings.ssl.base_dir }}/acme.sh
    - name: gosu {{ settings.ssl.user }} ./acme.sh --register-account --server {{ settings.ssl_acme_service }}
    - unless: test -f {{ settings.ssl.base_dir }}/acme.sh/ca/{{ settings.ssl_acme_domain }}/account.key
    - require:
      - archive: acme.sh
      - file: {{ settings.ssl.base_dir }}/acme.sh/acme.sh.env
      - file: {{ settings.ssl.base_dir }}/acme.sh/account.conf

  {%- if settings.ssl.acme.enabled and not (settings.ssl.key|d(false) and settings.ssl.cert|d(false)) %}
    {# issue host certificate, only if not disabled and ssl cert,key pair is not defined #}
{{ issue_cert(settings.server_name.split(' \t\n'),
  settings.ssl.acme.challenge, settings.ssl.acme.env) }}
  {%- endif %}

  {%- for virtual_host in settings.virtual_names %}
    {%- if virtual_host.acme.enabled|d(
            settings.ssl.acme.enabled) %}
{{ issue_cert(virtual_host.name.split(' '),
    virtual_host.acme.challenge|d(
      settings.ssl.acme.challenge),
    virtual_host.acme.env|d({})) }}
    {%- endif %}
  {%- endfor %}

{% endif %}


/etc/systemd/system/acme.service:
  file.managed:
    - source: salt://http_frontend/acme/acme.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/acme.service

/etc/systemd/system/acme.timer:
  file.managed:
    - source: salt://http_frontend/acme/acme.timer
    - require:
      - file: /etc/systemd/system/acme.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/acme.timer

enable-acme-service:
  service.running:
    - name: acme.timer
    - enable: true
    - require:
      - file: /etc/systemd/system/acme.service
      - file: /etc/systemd/system/acme.timer
    - watch:
      - file: /etc/systemd/system/acme.timer
