{% macro deploy_from_file(san_list, key_path, cert_path, chain_path, overwrite=true, onchanges="") %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

deploy_from_file_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }}
    - source: {{ cert_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
  {%- if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }}
  {%- endif %}
  {%- if onchanges != '' %}
    - onchanges:
      - {{ onchanges }}
  {%- endif %}

deploy_from_file_key_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }}
    - source: {{ key_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "640"
  {%- if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }}
  {%- endif %}
  {%- if onchanges != '' %}
    - onchanges:
      - {{ onchanges }}
  {%- endif %}
    - require:
      - file: deploy_from_file_cert_{{ domain }}

deploy_from_file_chain_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_chain_cert }}
    - source: {{ chain_path }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
  {%- if not overwrite %}
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_chain_cert }}
  {%- endif %}
  {%- if onchanges != '' %}
    - onchanges:
      - {{ onchanges }}
  {%- endif %}
    - require:
      - file: deploy_from_file_cert_{{ domain }}
{% endmacro %}


{% macro deploy_from_pillar(san_list, key, cert) %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

deploy_from_pillar_key_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "640"
    - contents: |
{{ key|indent(8, True) }}

deploy_from_pillar_cert_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
    - contents: |
{{ cert|indent(8, True) }}

deploy_from_pillar_chain_cert_{{ domain }}:
  file.managed:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_chain_cert }}
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
  {% set domain_dir= settings.ssl.base_dir ~ '/easyrsa/pki' %}

issue_local_ca_cert_{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} \
          /usr/local/bin/create-host-certificate.sh \
            {{ san_list|join(' ') }}
    - unless: |
        gosu {{ settings.ssl.user }}
          /usr/local/bin/create-host-certificate.sh --is-valid \
            {{ san_list|join(' ') }}
    - require:
      - file: /usr/local/bin/create-host-certificate.sh
    - require_in:
      - file: deploy_from_file_cert_{{ domain }}

{{ deploy_from_file(san_list,
  domain_dir ~ '/private/' ~ domain ~ '.key',
  domain_dir ~ '/issued/' ~ domain ~ '.crt',
  domain_dir ~ '/issued/' ~ domain ~ '.fullchain.crt',
  onchanges= 'cmd: issue_local_ca_cert_' ~ domain) }}

{% endmacro %}


{% macro issue_self_signed(san_list) %}
  {% from "http_frontend/defaults.jinja" import settings with context %}
  {% set domain= san_list[0] %}

issue_self_signed_cert_{{ domain }}:
  cmd.run:
    - name: |
        gosu {{ settings.ssl.user }} /usr/local/bin/create-selfsigned-host-cert.sh \
          -k {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }} \
          -c {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }} \
          {{ san_list|join(' ') }}
    - unless: |
        gosu {{ settings.ssl.user }} /usr/local/bin/create-selfsigned-host-cert.sh \
          --is-valid \
          -k {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_key }} \
          -c {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }} \
          {{ san_list|join(' ') }}
    - require:
      - file: /usr/local/bin/create-selfsigned-host-cert.sh

deploy_self_signed_chain_cert_{{ domain }}:
  file.copy:
    - name: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_chain_cert }}
    - source: {{ settings.ssl.base_dir }}/vhost/{{ domain }}/{{ settings.ssl_cert }}
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "644"
    - onchanges:
      - cmd: issue_self_signed_cert_{{ domain }}

{% endmacro %}
