{% macro issue_from_file(san_list, key_path, cert_path, chain_path, overwrite=true) %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

issue_from_file_key_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
    - source: {{ key_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "640"
  {% if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
  {% endif %}

issue_from_file_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_cert }}
    - source: {{ cert_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
  {% if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
  {% endif %}

issue_from_file_chain_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_chain_cert }}
    - source: {{ chain_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
  {% if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
  {% endif %}
{% endmacro %}


{% macro issue_from_pillar(san_list, key, cert) %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

issue_from_pillar_key_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "640"
    - contents: |
{{ key|indent(8, True) }}

issue_from_pillar_cert_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_cert }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
    - contents: |
{{ cert|indent(8, True) }}

issue_from_pillar_chain_cert_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_chain_cert }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
    - contents: |
{{ cert|indent(8, True) }}

{% endmacro %}



{% macro issue_from_local_ca(san_list) %}
  {# issue new cert, if not already available or SAN list != expected SAN list #}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}
  {% set domain_dir= settings.ssl.base_dir ~ '/easyrsa/pki/' ~ domain %}

local-ca-issue-cert-{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} \
          /usr/local/bin/create-host-certificate.sh \
            {{ san_list|join(' ') }}
    - unless: |
        gosu {{ settings.ssl.user }} \
          /usr/local/bin/create-host-certificate.sh --check-domains-listed \
            {{ san_list|join(' ') }}

local-ca-chain-cert-{{ domain }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ domain_dir }}/{{ domain }}.crt  \
            {{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_cert }} \
            > {{ domain_dir }}/{{ domain }}.{{ settings.ssl_chain_cert }}
    - require:
      - cmd: local-ca-issue-cert-{{ domain }}

local-ca-deploy-cert-{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} {{ settings.ssl.base_dir }}/ssl-renew-hook.sh \
            "{{ domain }}" \
            "{{ domain_dir }}/{{ domain }}.key" \
            "{{ domain_dir }}/{{ domain }}.crt" \
            "{{ domain_dir }}/{{ domain }}.{{ settings.ssl_chain_cert }}"
            "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_cert }}"
    - require:
      - cmd: local-ca-chain-cert-{{ domain }}

{% endmacro %}


{% macro issue_self_signed(san_list) %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

self-signed-deploy-{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} /usr/local/bin/create-selfsigned-host-cert.sh \
          -k {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }} \
          -c {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_chain_cert }} \
          {{ san_list|join(' ') }}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }}
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

{% endmacro %}
