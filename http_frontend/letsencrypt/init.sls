include:
  - http_frontend.dirs
  - http_frontend.nginx

{% from "http_frontend/defaults.jinja" import settings with context %}
{% set tlsport= settings.alpn_endpoint|regex_replace('^[^:]:([0-9]+)', '\\1') %}


{% macro issue_cert(san_list, challenge='alpn', env={}) %}
{# issue new cert, if not already available or SAN list != expected SAN list #}
{% set domain= san_list[0] %}
{% set domain_dir = settings.cert_dir+ '/acme.sh/' + domain %}

acme-issue-cert-{{ domain }}:
  cmd.run:
    - env:
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
  {%- for k,v in env.items() %}
      - {{ k }}: {{ v }}
  {%- endfor %}
    - cwd: {{ settings.cert_dir }}/acme.sh
    - name: |
        gosu {{ settings.cert_user }} ./acme.sh --issue \
          {% for i in san_list %}-d {{ i }} {% endfor %} \
  {%- if callenge.startswith('dns_') %}
          --dns {{ challenge }} \
  {%- else %}
          --alpn --tlsport {{ tlsport }} \
  {%- endif %}
          --renew-hook '{{ settings.cert_dir }}/cert-renew-hook.sh "$Le_Domain" "$CERT_KEY_PATH" "$CERT_PATH" "$CERT_FULLCHAIN_PATH" "$CA_CERT_PATH"'
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
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
    - cwd: {{ settings.cert_dir }}/acme.sh
    - name: |
        gosu {{ settings.cert_user }} {{ settings.cert_dir }}/cert-renew-hook.sh \
          "{{ settings.domain }}" \
          "{{ domain_dir }}/{{ domain }}.key" \
          "{{ domain_dir }}/{{ domain }}.cer" \
          "{{ domain_dir }}/fullchain.cer" \
          "{{ domain_dir }}/ca.cer"
    - onchanges:
      - cmd: acme-issue-cert-{{ domain }}
{% endmacro %}


{{ settings.cert_dir }}/acme.sh:
  file.directory:
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
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
    - name: {{ settings.cert_dir }}/acme.sh
    - source: {{ settings.external.acme_sh_tar_gz.target }}
    - archive_format: tar
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - enforce_toplevel: false
    - overwrite: true
    - clean: false
    - options: --strip-components 1
    - onchanges:
      - file: acme.sh
    - require:
      - file: {{ settings.cert_dir }}/acme.sh
      - file: acme.sh

{{ settings.cert_dir }}/acme.sh/acme.sh.env:
  file.managed:
    - mode: "0640"
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - contents: |
        export LE_WORKING_DIR="{{ settings.cert_dir }}/acme.sh"
        alias acme.sh="{{ settings.cert_dir }}/acme.sh/acme.sh"
    - require:
      - file: {{ settings.cert_dir }}/acme.sh


{% if not settings.letsencrypt %}
{# remove account.conf, to keep other parts from assuming it is enabeld #}
{{ settings.cert_dir }}/acme.sh/account.conf:
  file:
    - absent

{% else %}
{{ settings.cert_dir }}/acme.sh/account.conf:
  file.managed:
    - mode: "0640"
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
    - contents: |
        #LOG_FILE="{{ settings.cert_dir }}/acme.sh/acme.sh.log"
        #LOG_LEVEL=1
        #AUTO_UPGRADE="1"
        #NO_TIMESTAMP=1
        USER_PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'
        TLSPORT={{ tlsport }}
    - require:
      - file: {{ settings.cert_dir }}/acme.sh

acme-register-account:
  cmd.run:
    - env:
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
    - cwd: {{ settings.cert_dir }}/acme.sh
    - name: gosu {{ settings.cert_user }} ./acme.sh  --register-account
    - unless: test -f {{ settings.cert_dir }}/acme.sh/ca/acme-v02.api.letsencrypt.org/account.key
    - require:
      - archive: acme.sh
      - file: {{ settings.cert_dir }}/acme.sh/acme.sh.env
      - file: {{ settings.cert_dir }}/acme.sh/account.conf

  {%- if settings.letsencrypt.host and not (settings.key|d(false) and settings.cert|d(false)) %}
    {# issue host certificate, only if not disabled and ssl cert,key pair is not defined #}
{{ issue_cert(settings.server_name.split(' '),
  settings.letsencrypt.challenge, settings.letsencrypt.env) }}
  {%- endif %}

  {%- for virtual_host in settings.virtual_names %}
    {%- if virtual_host.letsencrypt.enabled|d(true) %}
{{ issue_cert(virtual_host.name.split(' '),
    virtual_host.letsencrypt.challenge|d('alpn'),
    virtual_host.letsencrypt.env|d({})) }}
    {%- endif %}
  {%- endfor %}

{% endif %}


/etc/systemd/system/letsencrypt.service:
  file.managed:
    - source: salt://http_frontend/letsencrypt/letsencrypt.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/letsencrypt.service

/etc/systemd/system/letsencrypt.timer:
  file.managed:
    - source: salt://http_frontend/letsencrypt/letsencrypt.timer
    - require:
      - file: /etc/systemd/system/letsencrypt.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/letsencrypt.timer

enable-letsencrypt-service:
  service.running:
    - name: letsencrypt.timer
    - enable: true
    - require:
      - file: /etc/systemd/system/letsencrypt.service
      - file: /etc/systemd/system/letsencrypt.timer
    - watch:
      - file: /etc/systemd/system/letsencrypt.timer
