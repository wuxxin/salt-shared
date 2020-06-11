{% macro podman_container(service_definition) %}
{%- from "containers/defaults.jinja" import settings, default_service with context %}
{%- set pod= salt['grains.filter_by']({'default': default_service},
  grain='default', default= 'default', merge=service_definition) %}

{# if not update on every container start , update now #}
{%- if not pod.container.update %}
update_image_{{ pod.image.name }}:
  cmd.run:
  {%- if pod.image.build %}
    - name: podman build {{ pod.image.build }} {{ "--tag="+ pod.image.tag if pod.image.tag }}
  {%- else %}
    - name: podman pull {{ pod.image.name }}{{ ":"+ pod.image.tag if pod.image.tag }}
  {%- endif %}
    - require_in:
      - file: {{ pod.container.name }}.service
{%- endif %}

{{ pod.container.name }}.service:
  file.managed:
    - source: salt://containers/podman/podman-template.service
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


{% macro storage_volume(name, labels=[], driver='local', opts=[]) %}
{%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
{%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
containers_volume_{{ name }}:
  cmd.run:
    - name: podman volume create --driver {{ driver }} {{ labels_string }} {{ opts_string }}
    - unless: podman ls -q | grep -q {{ name }}
{% endmacro %}

{% macro podman_compose(composefile) %}

{% endmacro %}
