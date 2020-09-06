
{% macro volume(name, labels=[], driver='local', opts=[]) %}
  {%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
nspawn_volume_{{ name }}:
  cmd.run:
    - name:
    - unless:
{% endmacro %}


{% macro image(name, tag='') %}
nspawn_image_{{ name }}:
  cmd.run:
    - name:
    - unless:
{% endmacro %}


{% macro container(container_definition) %}
  {%- from "nspawn/defaults.jinja" import settings, default_container with context %}
  {%- set this= salt['grains.filter_by']({'default': default_container},
    grain='default', default= 'default', merge=container_definition) %}

  {%- if not this.update %}
update_image_{{ this.image }}:
  cmd.run:
    - name:
    - require_in:
      - file: {{ this.name }}.service
  {%- endif %}

{{ this.name }}.env:
  file.managed:
    - name: {{ settings.container.service_basepath }}/{{ this.name }}.env
    - mode: 0600
    - contents: |
  {%- for key,value in this.environment.items() %}
        {{ key }}={{ value }}
  {%- endfor %}

{{ this.name }}.service:
  file.managed:
    - source: salt://containers/container-template.service
    - name: /etc/systemd/system/{{ this.name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ this.name }}.service
  {%- if this.enabled %}
  service.running:
    - enable: true
  {%- else %}
  service.dead:
    - enable: false
  {%- endif %}
    - name: {{ this.name }}.service
    - watch:
      - file: {{ this.name }}.env
      - file: {{ this.name }}.service
    - require:
      - cmd: {{ this.name }}.service
{% endmacro %}
