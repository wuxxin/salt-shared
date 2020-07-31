
{% macro podman_volume(name, labels=[], driver='local', opts=[]) %}
  {%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
containers_volume_{{ name }}:
  cmd.run:
    - name: podman volume create --driver {{ driver }} {{ labels_string }} {{ opts_string }} {{ name }}
    - unless: podman volume ls -q | grep -q {{ name }}
{% endmacro %}


{% macro podman_image(name, tag='') %}
podman_image_{{ name }}:
  cmd.run:
    - name: podman xxxx
    - unless: podman xxxx ls -q | grep -q {{ name }}
{% endmacro %}

{% macro podman_container(container_definition) %}
  {%- from "containers/defaults.jinja" import settings, default_container with context %}
  {%- set pod= salt['grains.filter_by']({'default': default_container},
    grain='default', default= 'default', merge=container_definition) %}

  {# if not update on every container start, update now on install state #}
  {%- if not pod.update %}
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
    - source: salt://containers/podman-container-template.service
    - name: /etc/systemd/system/{{ pod.container_name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ pod.container_name }}.service
  {%- if pod.enabled %}
  service.running:
    - enable: true
  {%- else %}
  service.dead:
    - enable: false
  {%- endif %}
    - name: {{ pod.container_name }}.service
    - require:
      - cmd: {{ pod.container_name }}.service
{% endmacro %}


{% macro podman_compose(compose_definition) %}
  {%- from "containers/defaults.jinja" import settings, default_compose with context %}
  {%- set compose= salt['grains.filter_by']({'default': default_compose},
    grain='default', default= 'default', merge=compose_definition) %}
  {%- set composetarget= "/etc/containers/podman-compose/"+ compose.service_name+ "/docker-compose.yml" %}
{{ compose.service_name }}.compose:
  file.managed:
    - source: {{ compose.composefile }}
    - name: {{ composetarget }}
    - makedirs: true
{{ compose.service_name }}.service:
  file.managed:
    - source: salt://containers/podman/podman-compose-template.service
    - name: /etc/systemd/system/{{ compose.service_name }}.service
    - template: jinja
    - defaults:
        compose: {{ compose }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ compose.service_name }}.service
  service.running:
    - name: {{ compose.service_name }}.service
    - enable: true
    - require:
      - cmd: {{ compose.service_name }}.service
{% endmacro %}
