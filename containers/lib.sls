
{% macro podman_volume(name, labels=[], driver='local', opts=[]) %}
  {%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
containers_volume_{{ name }}:
  cmd.run:
    - name: podman volume create --driver {{ driver }} {{ labels_string }} {{ opts_string }}
    - unless: podman volume ls -q | grep -q {{ name }}
{% endmacro %}


{% macro podman_container(service_definition) %}
  {%- from "containers/defaults.jinja" import settings, default_service with context %}
  {%- set pod= salt['grains.filter_by']({'default': default_service},
    grain='default', default= 'default', merge=service_definition) %}

  {# if not update on every container start, update now on install state #}
  {%- if not pod.container.update %}
update_image_{{ pod.image }}:
  cmd.run:
    {%- if pod.build %}
    - name: podman build {{ pod.build }} {{ "--tag="+ pod.tag if pod.tag }}
    {%- else %}
    - name: podman pull {{ pod.image }}{{ ":"+ pod.tag if pod.tag }}
    {%- endif %}
    - require_in:
      - file: {{ service_name }}.service
  {%- endif %}

{{ pod.container_name }}.service:
  file.managed:
    - source: salt://containers/podman/podman-template.service
    - name: /etc/systemd/system/{{ pod.container_name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ pod.container_name }}.service
  service.running:
    - name: {{ pod.container_name }}.service
    - enable: true
    - require:
      - cmd: {{ pod.container_name }}.service
{% endmacro %}


{% macro podman_compose(service_name, composefile, environment={}) %}
{{ service_name }}.service:
  file.managed:
    - source: salt://containers/podman/podman-compose-template.service
    - name: /etc/systemd/system/{{ service_name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ service_name }}.service
  service.running:
    - name: {{ service_name }}.service
    - enable: true
    - require:
      - cmd: {{ service_name }}.service

{% endmacro %}
