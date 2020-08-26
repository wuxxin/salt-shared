
{% macro volume(name, labels=[], driver='local', opts=[]) %}
  {%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
containers_volume_{{ name }}:
  cmd.run:
    - name: podman volume create --driver {{ driver }} {{ labels_string }} {{ opts_string }} {{ name }}
    - unless: podman volume ls -q | grep -q {{ name }}
{% endmacro %}


{% macro image(name, tag='') %}
containers_image_{{ name }}:
  cmd.run:
    - name: podman xxxx
    - unless: podman xxxx ls -q | grep -q {{ name }}
{% endmacro %}


{% macro container(container_definition) %}
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
      - file: {{ pod.name }}.service
  {%- endif %}

{{ pod.name }}.env:
  file.managed:
    - name: {{ settings.container.service_basepath }}/{{ pod.name }}.env
    - mode: 0600
    - contents: |
  {%- for key,value in pod.environment.items() %}
        {{ key }}={{ value }}
  {%- endfor %}

{{ pod.name }}.service:
  file.managed:
    - source: salt://containers/container-template.service
    - name: /etc/systemd/system/{{ pod.name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ pod.name }}.service
  {%- if pod.enabled %}
    {%- if pod.type == 'oneshot' %}
  service.enabled:
    {%- else %}
  service.running:
    - enable: true
    {%- endif %}
  {%- else %}
    {%- if pod.type == 'oneshot' %}
  service.disabled:
    {%- else %}
  service.dead:
    - enable: false
    {%- endif %}
  {%- endif %}
    - name: {{ pod.name }}.service
  {%- if pod.type != 'oneshot' %}
    - watch:
      - file: {{ pod.name }}.env
      - file: {{ pod.name }}.service
  {%- endif %}
    - require:
      - cmd: {{ pod.name }}.service
{% endmacro %}


{% macro compose(compose_definition) %}
  {%- from "containers/defaults.jinja" import settings, default_compose with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_compose},
    grain='default', default= 'default', merge=compose_definition) %}

  {%- if not entry.workdir %}
    {%- do entry.update({ 'workdir': settings.compose.workdir_basepath ~ '/' ~ entry.name }) %}
  {%- endif %}

  {%- set composefile= entry.workdir ~ "/" ~ settings.compose.base_filename %}
  {%- set overridefile= entry.workdir ~ "/" ~ settings.compose.override_filename %}

{# create workdir #}
{{ entry.name }}.workdir:
  file.directory:
    - name: {{ entry.workdir }}
    - makedirs: true
    - mode: "0750"

{# create compose,override files,
  fill with source,config or config,none if source empty #}
  {%- if entry.source %}
{{ entry.name }}.compose:
  file.managed:
    - source: {{ entry.source }}
    - name: {{ composefile }}
    - require:
      - file: {{ entry.name }}.workdir
{{ entry.name }}.override:
    {%- if entry.config %}
  file.managed:
    - contents: |
{{ entry.config|yaml(False)|indent(8,True) }}
    {%- else %}
  file.absent:
    {%- endif %}
    - name: {{ overridefile }}
    - require:
      - file: {{ entry.name }}.workdir
  {%- else %}
{{ entry.name }}.compose:
  file.managed:
    - contents: |
{{ entry.config|yaml(False)|indent(8,True) }}
    - name: {{ composefile }}
    - require:
      - file: {{ entry.name }}.workdir
{{ entry.name }}.override:
  file.absent:
    - name: {{ overridefile }}
  {%- endif %}

{# write files to workdir:
  if source then template jinja and environment else contents #}
  {%- for fname, fdata in entry.files.items() %}
{{ entry.name }}.files.{{ fname }}:
  file.managed:
    - name: {{ entry.workdir ~ "/" ~ fname }}
    - makedirs: true
    {%- if fdata.source is defined %}
    - source: {{ fdata.source }}
    - template: jinja
    - defaults:
      {%- for key,value in entry.environment.items() %}
        {{ key }}: {{ value }}
      {%- endfor %}
    {%- elif fdata.contents is defined %}
    - contents: |
{{ fdata.contents|indent(8,True) }}
    {%- endif %}
    {%- for k,v in fdata.items() %}
      {%- if k not in ['contents', 'source',] %}
    - {{ k }}: {{ v }}
      {%- endif %}
    {%- endfor %}
    - watch_in:
      - service: {{ entry.name }}.service
    - require:
      - file: {{ entry.name }}.workdir
  {%- endfor %}

{# write environment: to workdir #}
{{ entry.name }}.env:
  file.managed:
    - name: {{ entry.workdir ~ "/.env" }}
    - mode: 0600
    - contents: |
        # environment for {{ entry.name }}
  {%- for key,value in entry.environment.items() %}
        {{ key }}={{ value }}
  {%- endfor %}
    - require:
      - file: {{ entry.name }}.workdir

{# write, (re)load and start service #}
{{ entry.name }}.service:
  file.managed:
    - source: salt://containers/compose-template.service
    - name: /etc/systemd/system/{{ entry.name }}.service
    - template: jinja
    - defaults:
        compose: {{ entry }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ entry.name }}.service
  {%- if entry.enabled %}
  service.running:
    - enable: true
  {%- else %}
  service.dead:
    - enable: false
  {%- endif %}
    - name: {{ entry.name }}.service
    - require:
      - cmd: {{ entry.name }}.service
    - watch:
      - file: {{ entry.name }}.compose
      - file: {{ entry.name }}.override
      - file: {{ entry.name }}.env

{% endmacro %}
