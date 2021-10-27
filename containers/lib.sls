{# podman containers, highlevel library #}

{# i should not write complex code in a template language #}
{# i should not write complex code in a template language #}
{# i should not write complex code in a template language #}

{%- macro var_repl(data, envdict={}, user='') -%}
  {%- set var_repl_ns= namespace(data= data) -%}
  {%- set repl_names = salt['extutils.re_findall']('\$\{([^}]+?)\}', var_repl_ns.data) -%}
  {%- for varname in repl_names -%}
    {%- if envdict[varname] is defined -%}
      {%- set var_repl_ns.data = var_repl_ns.data|regex_replace('\$\{' ~ varname ~ '\}', envdict[varname]) -%}
    {%- endif -%}
  {%- endfor -%}
{{ var_repl_ns.data }}
{%- endmacro -%}

{%- macro repl_env_json(srcdict, envdict=False, user='') -%}
  {%- if not envdict -%}{%- set envdict = srcdict -%}{%- endif -%}
  {%- set repl_env_ns = namespace(to_repl=srcdict) -%}
  {%- for k,v in repl_env_ns.to_repl.items() -%}
    {%- if v is string and v != '' -%}
      {%- set repl_names = salt['extutils.re_findall']('\$\{([^}]+?)\}', v) -%}
      {%- if repl_names != None -%}
        {%- for varname in repl_names -%}
          {%- if envdict[varname] is defined -%}
            {%- do repl_env_ns.to_repl.update(
              {k: v|regex_replace('\$\{' ~ varname ~ '\}', envdict[varname]) } ) -%}
          {%- endif -%}
        {%- endfor -%}
      {%- endif -%}
    {%- endif -%}
  {%- endfor -%}
{{ repl_env_ns.to_repl|json() }}
{%- endmacro -%}


{%- macro repl_entry_json(entry, dirconfig=false, x11docker_options=[], user='') -%}
  {%- set repl_ns= namespace(to_repl={'environment': entry.environment}) -%}
  {# add SERVICE_NAME and USER, HOME #}
  {%- do repl_ns.to_repl.environment.update({'SERVICE_NAME': entry.name}) -%}
  {# add calculated user namespace id if needed for userns=pick or therelike #}
  {%- do repl_ns.to_repl.update({'USERNS_ID':
    salt['cmd.run_stdout'](
      'python -c "import binascii;id=(binascii.crc_hqx(b\'' ~ entry.name ~
        '\', 0) & 0x7fff); print(\'{:d}\'.format((id+ 0x4000 if id <=8 else id) << 16))"') }) -%}
  {# add x11docker template_options #}
  {%- do repl_ns.to_repl.update( {'desktop': entry.desktop} ) -%}
  {%- do repl_ns.to_repl.desktop.update( {'template_options': x11docker_options} ) -%}
  {%- if user != '' -%}
    {# add USER and HOME if user =! '' #}
    {%- do repl_ns.to_repl.environment.update({'USER': user, 'HOME': salt['user.info'](user)['home'] }) -%}
  {%- endif -%}
  {# add *dirs to entry #}
  {%- if dirconfig -%}
    {%- if user == '' -%}
      {%- set config_dict= {
        'configdir': dirconfig.system.config_basepath ~ '/' ~ entry.name,
        'workdir': dirconfig.system.workdir_basepath ~ '/' ~ entry.name,
        'builddir': dirconfig.system.build_basepath ~ '/' ~ entry.name,
        'servicedir': dirconfig.system.service_basepath,
        'scriptdir': dirconfig.system.script_basepath,
        'desktopdir': dirconfig.system.desktop_basepath,
        }
      -%}
    {%- else -%}
      {%- set config_dict= {
        'configdir': dirconfig.user.config_basepath ~ '/' ~ entry.name,
        'workdir': dirconfig.user.workdir_basepath ~ '/' ~ entry.name,
        'builddir': dirconfig.user.build_basepath ~ '/' ~ entry.name,
        'servicedir': dirconfig.user.service_basepath,
        'scriptdir': dirconfig.user.script_basepath,
        'desktopdir': dirconfig.user.desktop_basepath,
        }
      -%}
    {%- endif -%}
    {%- load_json as config_update -%}
{{ repl_env_json(config_dict, repl_ns.to_repl.environment, user=user) }}
    {%- endload -%}
    {%- do repl_ns.to_repl.update(config_update) -%}
  {%- endif -%}
  {# repl environment #}
  {%- load_json as env_update -%}
{{ repl_env_json(repl_ns.to_repl.environment, user=user) }}
  {%- endload -%}
  {%- do repl_ns.to_repl.update( {'environment': env_update} ) -%}
  {# repl labels #}
  {%- if entry.labels|d(false) -%}
    {%- load_json as labels_update -%}
{{ repl_env_json(entry.labels, repl_ns.to_repl.environment, user=user) }}
    {%- endload -%}
    {%- do repl_ns.to_repl.update( {'labels': labels_update} ) -%}
  {%- endif -%}
    {# repl storage #}
  {%- if entry.storage|d(false) -%}
    {%- do repl_ns.to_repl.update({'storage': []}) -%}
    {%- for s in entry.storage -%}
      {%- load_json as s_entry -%}
{{ repl_env_json(s, repl_ns.to_repl.environment, user=user) }}
      {%- endload -%}
      {%- do repl_ns.to_repl.storage.append(s_entry) -%}
    {%- endfor -%}
  {%- endif -%}
  {%- if entry.volumes|d(false) -%}
    {# repl volumes #}
    {%- do repl_ns.to_repl.update({'volumes': []}) -%}
    {%- for v in entry.volumes -%}
      {%- do repl_ns.to_repl.volumes.append(var_repl(v, repl_ns.to_repl.environment, user)) -%}
    {%- endfor -%}
  {%- endif -%}
  {%- if entry.ports|d(false) -%}
    {# repl ports #}
    {%- do repl_ns.to_repl.update({'ports': []}) -%}
    {%- for p in entry.ports -%}
      {%- do repl_ns.to_repl.ports.append(var_repl(p, repl_ns.to_repl.environment, user)) -%}
    {%- endfor -%}
  {%- endif -%}
{{ repl_ns.to_repl|json() }}
{%- endmacro -%}


{% macro create_directories(entry, user='') %}
{# create configdir, workdir, builddir and a symlink in workdir/build pointing to builddir #}
{{ entry.name }}.configdir:
  file.directory:
    - name: {{ entry.configdir }}
    - makedirs: true
    - mode: "0750"
  {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
  {%- endif %}
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
{# write environment to configdir if entry.enabled, else remove file #}
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
    - name: {{ entry.configdir }}/.env
{% endmacro %}


{% macro write_service(entry, source, user='') %}
  {# write systemd service file and start service if service, remove service if entry.absent #}
  {# XXX remove files from entry dict, may cause yaml issues #}
  {%- do entry.update({'files': {}})   %}
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
{# write shell script file (either for everyone or for one user) #}
{{ entry.name }}.script:
  file:
  {%- if entry.absent %}
    - absent
  {%- else %}
    - managed
    - source: salt://containers/template/container-run.sh
    - template: jinja
    - mode: 755
    {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
    {%- endif %}
    - defaults:
        entry: {{ entry }}
  {%- endif %}
    - name: {{ entry.scriptdir }}/{{ entry.name }}.sh
{% endmacro %}


{% macro write_desktop(entry, user='') %}
{# write desktop environment files (either for everyone or for one user) #}
{{ entry.name }}.desktop:
  file:
  {%- if entry.absent %}
    - absent
  {%- else %}
    - managed
    - source: salt://containers/template/container.desktop
    - template: jinja
    {%- if user != '' -%}
    - user: {{ user }}
    - group: {{ user }}
    {%- endif %}
    - defaults:
        entry: {{ entry }}
  {%- endif %}
    - name: {{ entry.desktopdir }}/{{ entry.name }}.desktop
{% endmacro %}


{% macro image(image_name, tag='', source='', buildargs={}, builddir= '', user='') %}
  {%- set tag_opt = '' if tag == '' else ':' ~ tag %}
  {%- set gosu_user = '' if user == '' else 'gosu ' ~ user ~ ' ' %}
  {%- set postfix_user = '' if user == '' else '_' ~ user %}
containers_image_{{ image_name }}{{ postfix_user }}:
  cmd.run:
  {%- if builddir == '' or source == '' %}
    - name: {{ gosu_user }} podman image pull {{ image_name }}{{ tag_opt }}
    - unless: {{ gosu_user }} podman image exists {{ image_name }}{{ tag_opt }}
  {%- else %}
    - cwd: {{ builddir }}
    - name: |
        {{ gosu_user }} podman build {{ '--tag='~ image_name~ ':' ~ tag|d('latest') }} \
        {%- for key,value in buildargs.items() %}
          {{ '--build-arg=' ~ key ~ '=' ~ value }} \
        {%- endfor %}
          {{ source }}
  {%- endif %}
{% endmacro %}


{% macro volume(volume_name, opts=[], labels={}, driver='local', user='') %}
  {%- set label_list = [] %}
  {%- for key,value in labels.items() %}
    {%- do label_list.append(' -l ' ~ key ~ '=' ~ value~ ' ') %}
  {%- endfor %}
  {%- set labels_str = label_list|join() %}
  {%- set opts_str = '' if not opts else '-o ' ~ opts|join(' -o ') %}
  {%- set gosu_user = '' if user == '' else 'gosu ' ~ user ~ ' ' %}
  {%- set postfix_user = '' if user == '' else '_' ~ user %}
containers_volume_{{ volume_name }}{{ postfix_user }}:
  cmd.run:
    - name: {{ gosu_user }} podman volume create --driver {{ driver }} {{ labels_str }} {{ opts_str }} {{ volume_name }}
    - unless: {{ gosu_user }} podman volume ls -q | grep -q {{ volume_name }}
{% endmacro %}


{%- macro volume_path(volume_name, container_definition, user='') -%}
  {%- from "containers/defaults.jinja" import settings, default_container with context -%}
  {%- set entry= salt['grains.filter_by']({'default': default_container},
  grain='default', default= 'default', merge=container_definition) -%}
  {%- load_json as entry_update -%}
{{ repl_entry_json(entry, user=user) }}
  {%- endload %}
  {%- do entry.update(entry_update) -%}
  {%- if user != '' -%}
{{ var_repl(settings.storage.rootless_storage_path ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
  {%- else -%}
{{ var_repl(settings.storage.graphroot ~ '/volumes/' ~ volume_name ~ '/_data', entry.env, user) }}
  {%- endif -%}
{%- endmacro -%}


{% macro container(container_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_container with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_container},
    grain='default', default= 'default', merge=container_definition) %}
  {% load_json as entry_update %}
{{ repl_entry_json(entry, dirconfig=settings.podman,
  x11docker_options=settings.x11docker[entry.desktop.template], user=user) }}
  {% endload %}
  {% do entry.update(entry_update) %}

{{ create_directories(entry, user=user) }}
{{ write_files(entry, user=user) }}
{{ write_env(entry, user=user) }}

  {%- if entry.enabled %}
    {# create volumes if defined via storage #}
    {%- for def in entry.storage %}
{{ volume(def.name, opts=def.opts|d([]), labels=def.labels|d({}),
          driver=def.driver|d('local'), user=user) }}
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
{{ write_service(entry, 'salt://containers/template/container.service', user=user) }}
  {%- elif entry.type in ['command', 'desktop'] %}
{{ write_script(entry, user=user) }}
    {%- if entry.type == 'desktop' %}
      {%- if entry.desktop.entry.Name is not defined %}
        {%- do entry.desktop.entry.update({'Name': entry.name}) %}
      {%- endif %}
      {%- if entry.desktop.entry.Exec is not defined %}
        {%- do entry.desktop.entry.update({'Exec': entry.name ~ '.sh'}) %}
      {%- endif %}
{{ write_desktop(entry, user=user) }}
    {%- endif %}
  {%- endif %}
{% endmacro %}


{% macro compose(compose_definition, user='') %}
  {%- from "containers/defaults.jinja" import settings, default_compose with context %}
  {%- set entry= salt['grains.filter_by']({'default': default_compose},
    grain='default', default= 'default', merge=compose_definition) %}
  {%- load_json as entry_update -%}
{{ repl_entry_json(entry, dirconfig=settings.compose,
  x11docker_options=settings.x11docker[entry.desktop.template], user=user) }}
  {%- endload -%}
  {%- do entry.update(entry_update) -%}

{{ create_directories(entry, user=user) }}
{{ write_files(entry, user) }}
{{ write_env(entry, user) }}

  {# create compose,override files, fill with source,config or config,none if source empty #}
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
