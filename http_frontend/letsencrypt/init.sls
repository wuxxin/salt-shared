{% from "http_frontend/defaults.jinja" import settings with context %}
{% set tlsport= settings.alpn_endpoint|regex_replace('^[^:]:([0-9]+)', '\\1') %}
{% set acme_sh_local_file= "/usr/local/"+ settings.external.acme_sh_tar_gz.target+ "/acme_sh.tar.gz" %}

include:
  - http_frontend.dirs
  - http_frontend.nginx

{{ settings.cert_dir }}/acme.sh:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - sls: http_frontend.dirs

acme.sh:
  pkg.installed:
    - pkgs:
      - openssl
      - socat
  file.managed:
    - name: {{ acme_sh_local_file}}
    - source: {{ settings.external.acme_sh_tar_gz.download }}
    - source_hash: sha256={{ settings.external.acme_sh_tar_gz.hash }}
    - require:
      - pkg: acme.sh
  archive.extracted:
    - name: {{ settings.cert_dir }}/acme.sh
    - source: {{ acme_sh_local_file }}
    - archive_format: tar
    - user: {{ settings.user }}
    - group: {{ settings.user }}
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
    - mode: "0644"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - contents: |
        export LE_WORKING_DIR="{{ settings.cert_dir }}/acme.sh"
        alias acme.sh="{{ settings.cert_dir }}/acme.sh/acme.sh"
    - require:
      - file: {{ settings.cert_dir }}/acme.sh

{% if settings.letsencrypt and
    not (settings.key|d(false) and settings.cert|d(false)) %}
    {# use letsencrypt but only if we dont have a ssl key pair defined #}

{{ settings.cert_dir }}/acme.sh/account.conf:
  file.managed:
    - mode: "0644"
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - contents: |
        #LOG_FILE="{{ settings.cert_dir }}/acme.sh/acme.sh.log"
        #LOG_LEVEL=1
        #AUTO_UPGRADE="1"
        #NO_TIMESTAMP=1
        USER_PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'
        TLSPORT={{ tlsport }}
        DOMAIN={{ settings.domain }}
    - require:
      - file: {{ settings.cert_dir }}/acme.sh

acme-register-account:
  cmd.run:
    - name: gosu {{ settings.user }} ./acme.sh  --register-account
    - env:
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
    - cwd: {{ settings.cert_dir }}/acme.sh
    - unless: test -f {{ settings.cert_dir }}/acme.sh/ca/acme-v02.api.letsencrypt.org/account.key
    - require:
      - archive: acme.sh
      - file: {{ settings.cert_dir }}/acme.sh/acme.sh.env
      - file: {{ settings.cert_dir }}/acme.sh/account.conf

{# issue new cert, if not already available or SAN list != expected SAN list #}
{% set domain_dir = settings.cert_dir+ '/acme.sh/' + settings.domain %}
acme-issue-cert:
  cmd.run:
    - name: |
        gosu {{ settings.user }} ./acme.sh --issue \
        {% for i in settings.allowed_hosts %}-d {{ i }} {% endfor %} \
        --alpn --tlsport {{ tlsport }} \
        --renew-hook '{{ settings.cert_dir }}/cert-renew-hook.sh "$Le_Domain" "$CERT_KEY_PATH" "$CERT_PATH" "$CERT_FULLCHAIN_PATH" "$CA_CERT_PATH"'
    - env:
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
    - unless: |
        result="false"
        if test -f "{{ domain_dir }}/fullchain.cer"; then
          if test -f "{{ domain_dir }}/{{ settings.domain }}.cer"; then
            san_list=$(openssl x509 -text -noout \
              -in "{{ domain_dir }}/{{ settings.domain }}.cer" | \
              awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | \
              tr -d "DNS:" | tr "," "\\n" | sort)
            exp_list=$(echo "{{ settings.allowed_hosts|join(' ') }}" | \
              tr " " "\\n" | sort)
            if test "$san_list" = "$exp_list"; then
              result="true"
            fi
          fi
        fi
        $result
    - cwd: {{ settings.cert_dir }}/acme.sh
    - require:
      - cmd: acme-register-account
      - service: nginx

{# DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" #}
acme-deploy:
  cmd.run:
    - name: |
        gosu {{ settings.user }} {{ settings.cert_dir }}/cert-renew-hook.sh \
        "{{ settings.domain }}" \
        "{{ domain_dir }}/{{ settings.domain }}.key" \
        "{{ domain_dir }}/{{ settings.domain }}.cer" \
        "{{ domain_dir }}/fullchain.cer" \
        "{{ domain_dir }}/ca.cer"
    - env:
      - LE_WORKING_DIR: "{{ settings.cert_dir }}/acme.sh"
    - cwd: {{ settings.cert_dir }}/acme.sh
    - onchanges:
      - cmd: acme-issue-cert

{% else %}

{{ settings.cert_dir }}/acme.sh/account.conf:
  file:
    - absent

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
