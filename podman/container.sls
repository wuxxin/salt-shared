
{% macro podman_container(service_definition) %}
{%- from "podman/defaults.jinja" import settings, default_service with context %}
{%- set pod= salt['grains.filter_by']({'default': default_service},
  grain='default', default= 'default', merge=service_definition) %}

{%- if not pod.container.update_on_start %}
  {# if not update on every container start , update now #}
update_image_{{ pod.image.name }}:
  cmd.run:
  {%- if pod.image.build %}
    - name: podman build bla
  {%- else %}
    - name: podman pull bla
  {%- endif %}
    - require_in:
      - file: {{ pod.container.name }}.service
{%- endif %}

{{ pod.container.name }}.service:
  file.managed:
    - source: salt://podman/container-template.service
    - name: /etc/systemd/system/{{ pod.container.name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ pod.container.name }}.service
  service.running:
    - name: {{ pod.container.name }}.service
    - enable: true
    - require:
      - cmd: {{ pod.container.name }}.service
{% endmacro %}
