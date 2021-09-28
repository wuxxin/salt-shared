{% macro issue_from_file(san_list, key_path, cert_path, chain_path) %}
  {% set domain= san_list[0] %}

issue_from_file_key_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_key }}
    - source: {{ key_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
issue_from_file_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_cert }}
    - source: {{ cert_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
issue_from_file_chain_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ settings.ssl_chain_cert }}
    - source: {{ chain_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
{% endmacro %}


{% macro issue_from_pillar(san_list, key, cert) %}
  {% set domain= san_list[0] %}

{{ settings.ssl.base_dir }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ key|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs

  {% for i in [settings.ssl_cert, settings.ssl_chain_cert] %}
{{ settings.ssl.base_dir }}/{{ i }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ cert|indent(8, True) }}
    - require:
      - sls: http_frontend.dirs
  {% endfor %}

{{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}/{{ settings.ssl_key }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ virtual_host.key|indent(8, True) }}
    - require:
      - file: {{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}
    {% for i in [virtual_host.ssl_cert, virtual_host.ssl_chain_cert] %}
{{ settings.ssl.base_dir }}/vhost/{{ i }}:
  file.managed:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
{{ virtual_host.cert|indent(8, True) }}
    - require:
      - file: {{ settings.ssl.base_dir }}/vhost/{{ vhost_domain }}
    {% endfor %}

{% endmacro %}


{% macro issue_self_signed(san_list) %}
  {% set domain= san_list[0] %}

self-signed-deploy-{{ domain }}:
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


{% macro issue_from_local_ca(san_list) %}
  {# issue new cert, if not already available or SAN list != expected SAN list #}
  {% set domain= san_list[0] %}
  {% set domain_dir = settings.ssl.base_dir+ '/easyrsa/pki/' + domain %}

local-ca-issue-cert-{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} \
          /usr/local/sbin/create-host-certificate.sh \
            {{ san_list.split(' \n\t')|join(' ') }}
    - unless: |
        gosu {{ settings.ssl.user }} \
          /usr/local/sbin/create-host-certificate.sh --check-domains-listed \
            {{ san_list.split(' \n\t')|join(' ') }}

local-ca-chain-cert-{{ domain }}:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - umask: 027
    - name: |
        cat {{ domain_dir }}/{{ domain }}.crt  \
            {{ settings.ssl.base_dir }}/{{ ssl_local_ca_cert }} \
            > {{ domain_dir }}/{{ domain }}.{{ settings.ssl_chain_cert }}
  - require:
    - cmd: local-ca-issue-cert-{{ domain }}

local-ca-deploy-cert-{{ domain }}:
  - name: |
      gosu {{ settings.ssl.user }} {{ settings.ssl.base_dir }}/ssl-renew-hook.sh \
        "{{ domain }}" \
        "{{ domain_dir }}/{{ domain }}.key" \
        "{{ domain_dir }}/{{ domain }}.crt" \
        "{{ domain_dir }}/{{ domain }}.{{ settings.ssl_chain_cert }}"
        "{{ settings.ssl.base_dir }}/{{ ssl_local_ca_cert }}"
  - require:
    - cmd: local-ca-chain-cert-{{ domain }}

{% endmacro %}
