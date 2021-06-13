{%- macro env_repl(data, env={}, user='') -%}
{%- if user != '' -%}
{%- set repl_env= env + {'USER': user, 'HOME': salt['user.info'](user)['home'] } -%}
{%- else -%}
{%- set repl_env= env -%}
{%- endif -%}
{%- set repl_ns= namespace(data= data) -%}
{%- set repl_names= repl_ns.data|regex_search('\$\{(.+)\}') -%}
{%- if repl_names != None -%}
  {%- for varname in repl_names -%}
    {%- set repl_ns.data = repl_ns.data|regex_replace('\$\{' ~ varname ~ '\}', repl_env[varname]) -%}
  {%- endfor -%}
{%- endif -%}
{{ repl_ns.data }}
{%- endmacro -%}


{%- macro usernsid_fromstr(name) -%}
{{ salt['cmd.run_stdout'](
  'python -c "import binascii;id=(binascii.crc_hqx(b\'' ~
  name ~ '\', 0) & 0x7fff); print(\'{:d}\'.format((id+ 0x4000 if id <=8 else id) << 16))"') }}
{%- endmacro -%}


{%- macro build_path(name, user='') -%}
{%- from "containers/defaults.jinja" import settings with context -%}
{%- if user != '' -%}
{{ env_repl(settings.podman.user_build_basepath ~ '/' ~ name, {}, user) }}
{%- else -%}
{{ settings.podman.build_basepath ~ '/' ~ name }}
{%- endif -%}
{%- endmacro -%}


{%- macro service_path(name, user='') -%}
{%- from "containers/defaults.jinja" import settings with context -%}
{%- if user != '' -%}
{{ env_repl(settings.podman.user_workdir_basepath ~ '/' ~ name, {}, user) }}
{%- else -%}
{{ settings.podman.workdir_basepath ~ '/' ~ name }}
{%- endif -%}
{%- endmacro -%}


{% macro create_directories(entry) %}
{# create workdir, builddir and a symlink in workdir/build pointing to builddir #}
{{ entry.name }}.workdir:
  file.directory:
    - name: {{ entry.workdir }}
    - makedirs: true
    - mode: "0750"
{{ entry.name }}.builddir:
  file.directory:
    - name: {{ entry.builddir }}
    - makedirs: true
{{ entry.name }}.workdir.builddir.symlink:
  file.symlink:
    - name: {{ entry.workdir }}/build
    - target: {{ entry.builddir }}
    - require:
      - file: {{ entry.name }}.workdir
      - file: {{ entry.name }}.builddir
{% endmacro %}


{% macro write_files(entry) %}
{# if entry.enabled, write files to workdir else delete files from workdir,
  if source defined and is template, template context will have environment populated #}
  {%- for fname, fdata in entry.files.items() %}
{{ entry.name }}.files.{{ fname }}:
  file:
    {%- if not entry.enabled %}
    - absent
    - name: {{ entry.workdir ~ "/" ~ fname }}
    {%- else %}
    - managed
    - name: {{ entry.workdir ~ "/" ~ fname }}
    - makedirs: true
      {%- if fdata.contents is defined %}
    - contents: |
{{ fdata.contents|indent(8,True) }}
      {%- else %}
    - defaults:
        {%- for key,value in entry.environment.items() %}
        {{ key }}: {{ value }}
        {%- endfor %}
        {%- if fdata.defaults is defined %}
          {%- for key,value in fdata.defaults.items() %}
        {{ key }}: {{ value }}
          {%- endfor %}
        {%- endif %}
      {%- endif %}
      {%- for k,v in fdata.items() %}
        {%- if k not in ['contents', 'defaults', ] %}
    - {{ k }}: {{ v }}
        {%- endif %}
      {%- endfor %}
      {%- if entry.type in ['service', 'oneshot'] %}
    - watch_in:
      - service: {{ entry.name }}.service
      {%- endif %}
    - require:
      - file: {{ entry.name }}.workdir
      - file: {{ entry.name }}.builddir
    {%- endif %}
  {%- endfor %}
{% endmacro %}


{% macro write_env(entry) %}
{# write environment to workdir if entry.enabled, else remove file #}
{{ entry.name }}.env:
  file:
  {%- if entry.enabled %}
    - managed
    - mode: 0600
    - contents: |
        # environment for {{ entry.name }}
    {%- for key,value in entry.environment.items() %}
        {{ key }}={{ value }}
    {%- endfor %}
  {%- else %}
    - absent
  {%- endif %}
    - name: {{ entry.workdir }}.env
{% endmacro %}


{% macro write_service(entry) %}
{# write systemd service file and start service if service, remove service if entry.absent #}
{{ entry.name }}.service:
  file:
  {%- if entry.absent %}
    - absent
  {%- else %}
    - managed
    - source: salt://containers/template/container.service
    - template: jinja
    - defaults:
        entry: {{ entry }}
        settings: {{ settings }}
  {%- endif %}
    - name: {{ entry.servicedir }}/{{ entry.name }}.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ entry.name }}.service
  {%- if entry.enabled and not entry.absent %}
    {%- if entry.type == 'oneshot' %}
  service.enabled:
    {%- else %}
  service.running:
    - enable: true
    {%- endif %}
  {%- else %}
    {%- if entry.type == 'oneshot' %}
  service.disabled:
    {%- else %}
  service.dead:
    - enable: false
    {%- endif %}
  {%- endif %}
    - name: {{ entry.name }}.service
  {%- if entry.type != 'oneshot' and not entry.absent %}
    - watch:
      - file: {{ entry.name }}.env
      - file: {{ entry.name }}.service
  {%- endif %}
    - require:
      - cmd: {{ entry.name }}.service
{% endmacro %}


{% macro volume(name, opts=[], driver='local', labels=[], env={}, user='') %}
  {%- set name_str = env_repl(name, env, user) %}
  {%- set labels_str = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_str = '' if not opts else '-o ' ~ opts|join(' -o ') %}
  {%- set gosu_user = '' if user == '' else 'gosu ' ~ user ~ ' ' %}
  {%- set postfix_user = '' if user == '' else '_' ~ user %}
containers_volume_{{ name_str }}{{ postfix_user }}:
  cmd.run:
    - name: {{ gosu_user }} podman volume create --driver {{ driver }} {{ labels_str }} {{ opts_str }} {{ name_str }}
    - unless: {{ gosu_user }} podman volume ls -q | grep -q {{ name_str }}
{% endmacro %}


{% macro image(name, tag='', source='', buildargs={}, builddir= '', user='') %}
  {%- set tag_opt = '' if tag == '' else ':' ~ tag %}
  {%- set gosu_user = '' if user == '' else 'gosu ' ~ user ~ ' ' %}
  {%- set postfix_user = '' if user == '' else '_' ~ user %}
containers_image_{{ name }}{{ postfix_user }}:
  cmd.run:
  {%- if builddir == '' or source == '' %}
    - name: {{ gosu_user }} podman image pull {{ name }}{{ tag_opt }}
    - unless: {{ gosu_user }} podman image exists {{ name }}{{ tag_opt }}
  {%- else %}
    - cwd: {{ builddir }}
    - name: |
        {{ gosu_user }} podman build {{ '--tag='~ name~ ':' ~ tag|d('latest') }} \
        {%- for key,value in buildargs.items() %}
          {{ '--build-arg=' ~ key ~ '=' ~ value }} \
        {%- endfor %}
          {{ source }}
  {%- endif %}
{% endmacro %}


{% macro container(container_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_container with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_container},
    grain='default', default= 'default', merge=container_definition) %}

  {# add SERVICE_NAME to environment, so volume, storage, ports can pick it up #}
  {%- do entry.environment.update({'SERVICE_NAME': entry.name}) %}
  {%- if user != '' %}
    {%- do entry.environment.update({
        'USER': user, 'HOME': salt['user.info'](user)['home'] }) %}
    {%- do entry.update({
        'workdir': env_repl(settings.podman.user_workdir_basepath ~ '/' ~ entry.name, entry.environment),
        'builddir': env_repl(settings.podman.user_build_basepath ~ '/' ~ entry.name, entry.environment),
        'servicedir': env_repl(settings.podman.user_service_basepath ~ '/' ~ entry.name, entry.environment),
      }) %}
  {%- else %}
    {%- do entry.update(
      { 'workdir': settings.podman.workdir_basepath ~ '/' ~ entry.name,
        'builddir': settings.podman.build_basepath ~ '/' ~ entry.name,
        'servicedir': settings.podman.service_basepath ~ '/' ~ entry.name,
      }) %}
  {%- endif %}

{{ create_directories(entry) }}
{{ write_files(entry) }}
{{ write_env(entry) }}

  {%- if entry.enabled %}
    {# create volumes if defined via storage #}
    {%- for def in entry.storage %}
{{ volume(def.name, opts=def.opts|d([]), driver=def.driver|d('local'),
          labels=def.labels|d([]), env=entry.environment, user=user) }}
    {%- endfor %}

    {# if not update on every container start, update now on install state #}
    {%- if not entry['update'] or entry.type == 'build' %}
      {%- if entry.type == 'build' %}
{{ image(entry.image, entry.tag, entry.build.source, entry.build.args, entry.builddir, user=user) }}
      {%- else %}
{{ image(entry.image, entry.tag, entry.build.source, entry.build.args, entry.builddir, user=user,
    require_in='file: ' ~ entry.name~ '.service') }}
      {%- endif %}
    {%- endif %}
  {%- endif %}

  {%- if entry.type in ['service', 'oneshot'] %}
{{ write_service(entry) }}
  {%- endif %}

{% endmacro %}


{%- macro container_volume_path(volume_name, container_definition, user='') -%}
{%- from "containers/defaults.jinja" import settings, default_container with context -%}
{%- set entry= salt['grains.filter_by']({'default': default_container},
  grain='default', default= 'default', merge=container_definition) -%}
{%- do entry.environment.update({'SERVICE_NAME': entry.name}) -%}
{%- if user != '' -%}
{{ env_repl(settings.storage.rootless_storage_path ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
{%- else -%}
{{ env_repl(settings.storage.graphroot ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
{%- endif %}
{%- endmacro -%}


{% macro compose(compose_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_compose with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_compose},
    grain='default', default= 'default', merge=compose_definition) %}

  {# add SERVICE_NAME to environment, so volume, storage, ports can pick it up #}
  {%- do entry.environment.update({'SERVICE_NAME': entry.name}) %}
  {%- if user != '' %}
    {%- do entry.environment.update({'USER': user, 'HOME': salt['user.info'](user)['home'] }) %}
    {%- if not entry.workdir %}
      {%- do entry.update({'workdir':
        env_repl(settings.compose.user_workdir_basepath ~ '/' ~ entry.name, entry.environment)}) %}
    {%- endif %}
    {%- if not entry.builddir %}
      {%- do entry.update({'builddir':
        env_repl(settings.compose.user_build_basepath ~ '/' ~ entry.name, entry.environment)}) %}
    {%- endif %}
  {%- else %}
    {%- if not entry.workdir %}
      {%- do entry.update({'workdir':
        env_repl(settings.compose.workdir_basepath ~ '/' ~ entry.name)}) %}
    {%- endif %}
    {%- if not entry.builddir %}
      {%- do entry.update({'builddir':
        env_repl(settings.compose.build_basepath ~ '/' ~ entry.name)}) %}
    {%- endif %}
  {%- endif %}

  {%- set composefile= entry.workdir ~ "/" ~ settings.compose.compose_filename %}
  {%- set overridefile= entry.workdir ~ "/" ~ settings.compose.override_filename %}

{# create compose,override files,
  fill with source,config or config,none if source empty #}
  {%- if not entry.enabled %}
{{ entry.name }}.compose:
  file.absent:
    - name: {{ composefile }}
{{ entry.name }}.override:
  file.absent:
    - name: {{ overridefile }}
  {%- else %}
    {%- if entry.source != None %}
{{ entry.name }}.compose:
  file.managed:
    - source: {{ entry.source }}
    - name: {{ composefile }}
    - require:
      - file: {{ entry.name }}.workdir
{{ entry.name }}.override:
      {%- if entry.config %}
  file.managed:
    - mode: "0600"
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
  {%- endif %}

{# write, (re)load and start service #}
{{ entry.name }}.service:
  file:
    {%- if entry.absent %}
    - absent
    {%- else %}
    - managed
    - source: salt://containers/template/compose.service
    - template: jinja
    - defaults:
        entry: {{ entry }}
    {%- endif %}
    - name: /etc/systemd/system/{{ entry.name }}.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ entry.name }}.service
  {%- if entry.enabled and not entry.absent %}
  service.running:
    - enable: true
  {%- else %}
  service.dead:
    - enable: false
  {%- endif %}
    - name: {{ entry.name }}.service
    - require:
      - cmd: {{ entry.name }}.service
  {%- if not entry.absent %}
    - watch:
      - file: {{ entry.name }}.compose
      - file: {{ entry.name }}.override
      - file: {{ entry.name }}.env
  {%- endif %}

{% endmacro %}
