{# podman containers, highlevel library #}
{#
lowlevel functions:
  + env_repl(data, env={}, user='')
  + name_to_usernsid(name)
  + get_dirs_json(entry, config, user='')
  + create_directories(entry, user='')
  + write_files(entry, user='')
  + write_env(entry, user='')
  + write_service(entry, source, user='')
  + write_script(entry, user='')
  + write_desktop(entry, user='')

highlevel functions:
  + image(name, tag='', source='', buildargs={}, builddir= '', user='')
  + volume(name, opts=[], driver='local', labels=[], env={}, user='')
  + volume_path(volume_name, container_definition, user='')
  + container(container_definition, user='')
  + compose(compose_definition, user='')
#}


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


{%- macro name_to_usernsid(name) -%}
{{ salt['cmd.run_stdout'](
  'python -c "import binascii;id=(binascii.crc_hqx(b\'' ~
  name ~ '\', 0) & 0x7fff); print(\'{:d}\'.format((id+ 0x4000 if id <=8 else id) << 16))"') }}
{%- endmacro -%}


{%- macro get_dirs_json(entry, config, user='') -%}
  {%- if user == '' -%}
    {%- set dirs_dict= {
        'configdir': config.system.config_basepath ~ '/' ~ entry.name,
        'workdir': config.system.workdir_basepath ~ '/' ~ entry.name,
        'builddir': config.system.build_basepath ~ '/' ~ entry.name,
        'servicedir': config.system.service_basepath,
        'scriptdir': config.system.script_basepath,
        'desktopdir': config.system.desktop_basepath,
        }
    -%}
  {%- else -%}
    {%- set dirs_dict= {
        'configdir': env_repl(config.user.config_basepath ~ '/' ~ entry.name, entry.environment),
        'workdir': env_repl(config.user.workdir_basepath ~ '/' ~ entry.name, entry.environment),
        'builddir': env_repl(config.user.build_basepath ~ '/' ~ entry.name, entry.environment),
        'servicedir': env_repl(config.user.service_basepath, entry.environment),
        'scriptdir': env_repl(config.user.script_basepath, entry.environment),
        'desktopdir': env_repl(config.user.desktop_basepath, entry.environment),
        }
    -%}
  {%- endif -%}
{{ dirs_dict|json() }}
{%- endmacro -%}


{% macro create_directories(entry, user='') %}
{# create workdir, builddir and a symlink in workdir/build pointing to builddir #}
{{ entry.name }}.workdir:
  file.directory:
    - name: {{ entry.workdir }}
    - makedirs: true
    - mode: "0750"
  {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
  {%- endif %}
{{ entry.name }}.builddir:
  file.directory:
    - name: {{ entry.builddir }}
    - makedirs: true
  {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
  {%- endif %}
{{ entry.name }}.workdir.builddir.symlink:
  file.symlink:
    - name: {{ entry.workdir }}/build
    - target: {{ entry.builddir }}
  {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
  {%- endif %}
    - require:
      - file: {{ entry.name }}.workdir
      - file: {{ entry.name }}.builddir
{% endmacro %}


{% macro write_files(entry, user='') %}
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
      {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
      {%- endif %}
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


{% macro write_env(entry, user='') %}
{# write environment to workdir if entry.enabled, else remove file #}
{{ entry.name }}.env:
  file:
  {%- if entry.enabled %}
    - managed
    - mode: 0600
    {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
    {%- endif %}
    - contents: |
        # environment for {{ entry.name }}
    {%- for key,value in entry.environment.items() %}
        {{ key }}={{ value }}
    {%- endfor %}
  {%- else %}
    - absent
  {%- endif %}
    - name: {{ entry.configdir }}.env
{% endmacro %}


{% macro write_service(entry, source, user='') %}
  {# write systemd service file and start service if service, remove service if entry.absent #}
  {%- from "containers/defaults.jinja" import settings with context -%}
{{ entry.name }}.service:
  file:
  {%- if entry.absent %}
    - absent
  {%- else %}
    - managed
    - source: {{ source }}
    - template: jinja
    {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
    {%- endif %}
    - defaults:
        entry: {{ entry }}
        settings: {{ settings }}
        user: {{ user }}
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


{% macro write_script(entry, user='') %}
{# write shell script file #}
{% endmacro %}


{% macro write_desktop(entry, user='') %}
{# write desktop environment files (either for everyone or for one user) #}
{#
/usr/local
~/.local
/share/applications/android-{{ name }}.desktop:
/usr/local
~/.local
/bin/android-{{ name }}.sh:
#}
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


{%- macro volume_path(volume_name, container_definition, user='') -%}
{%- from "containers/defaults.jinja" import settings, default_container with context -%}
{%- set entry= salt['grains.filter_by']({'default': default_container},
  grain='default', default= 'default', merge=container_definition) -%}
{%- do entry.environment.update({'SERVICE_NAME': entry.name}) -%}
{%- if user != '' -%}
{%- do entry.environment.update({'USER': user, 'HOME': salt['user.info'](user)['home'] }) -%}
{{ env_repl(settings.storage.rootless_storage_path ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
{%- else -%}
{{ env_repl(settings.storage.graphroot ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
{%- endif %}
{%- endmacro -%}


{% macro container(container_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_container with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_container},
    grain='default', default= 'default', merge=container_definition) %}

  {%- do entry.environment.update({'SERVICE_NAME': entry.name}) -%}
  {%- if user != '' -%}
  {%- do entry.environment.update({'USER': user, 'HOME': salt['user.info'](user)['home'] }) -%}
  {%- endif %}
  {% load_json as config_update %}
{{ get_dirs_json(entry, settings.podman, user=user) }}
  {% endload %}
  {% do entry.update(config_update) %}

{{ create_directories(entry, user) }}
{{ write_files(entry, user) }}
{{ write_env(entry, user) }}

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
{{ write_service(entry, 'salt://containers/template/container.service', user) }}
  {%- elif entry.type in ['command', 'desktop'] %}
{{ write_script(entry, user) }}
  {%- endif %}
{% endmacro %}


{% macro compose(compose_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_compose with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_compose},
    grain='default', default= 'default', merge=compose_definition) %}

  {%- do entry.environment.update({'SERVICE_NAME': entry.name}) -%}
  {%- if user != '' -%}
  {%- do entry.environment.update({'USER': user, 'HOME': salt['user.info'](user)['home'] }) -%}
  {%- endif %}
  {% load_json as config_update %}
  {{ get_dirs_json(entry, settings.compose, user=user) }}
  {% endload %}
  {% do entry.update(config_update) %}

{{ write_files(entry, user) }}
{{ write_env(entry, user) }}

{# create compose,override files,
  fill with source,config or config,none if source empty #}
  {%- set composefile= entry.workdir ~ "/" ~ settings.compose.compose_filename %}
  {%- set overridefile= entry.workdir ~ "/" ~ settings.compose.override_filename %}
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
{{ write_service(entry, 'salt://containers/template/compose.service', user) }}

{% endmacro %}
