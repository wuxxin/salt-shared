{% from "roles/dokku/defaults.jinja" import settings as s with context %}


{% macro dokku(command, param1, param2=None) %}
{% set opt_para="" if param2 == None else param2 %}
"{{ command }}_{{ param1 }}_{{ opt_para }}":
  cmd.run:
    - name: dokku {{ command }} {{ param1 }} {{ opt_para }}
{% endmacro %}


{% macro dokku_pipe(pipedata, command, param1) %}
"{{ command }}_{{ param1 }}":
  module.run:
    - name: cmd.run
    - cmd: dokku {{ command }} {{ param1 }}
    - stdin: |
{{ pipedata|indent(8, True) }}
{% endmacro %}

{% macro dokku_build_static(name, data) %}
{#
source:
  build_static:
    dockerfile:
    url:
    mount: "-v $(pwd):/go/"
#}
{% endmacro %}

{% macro dokku_checkout(name, data) %}
{#
source:
  url: url or ./local-non-git-directory
  branch: branch name (default=master)
  submodules: *true/false
  identity: filepath/to/identity
#}
{% if data['source']['url'][:1] == "." %}
{{ name }}_dir:
  file.directory:
    - name: {{ s.templates.target }}/{{ name }}
{{ name }}_checkout:
  file.recurse:
    - name: {{ s.templates.target }}/{{ name }}
    - source: salt://templates/dokku/{{ name }}/{{ data['source']['url'][2:] }}
    - user: {{ s.user }}
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: git init; git add .; git config user.email "saltmaster@localhost"; git config user.name "Salt Master"; git commit -a -m "initial commit"
    - user: {{ s.user }}
{% else %}

  {% if data['source']['identity'] is defined %}
{{ name }}_ssh_command:
  file.managed:
    - name: {{ s.templates.target }}/{{ name }}-sshcommand
    - mode: '0755'
    - user: {{ s.user }}
    - contents: |
        #!/bin/bash
        ssh -i {{ s.templates.target }}/{{ name }}.identity.secret "$@"

{{ name }}_copy_identity:
  file.copy:
    - source: {{ data['source']['identity'] }}
    - name: {{ s.templates.target }}/{{ name }}.identity.secret
    - user: {{ s.user }}
    - mode: '0600'
    - force: true

    {% set git_ssh='GIT_SSH="'+ s.templates.target+ '/'+name+ '-sshcommand"' %}
  {% else %}
    {% set git_ssh='' %}
  {% endif %}
  {% set br_requested = data ['source']['branch']|d('master') %}

{{ name }}_checkout:
  cmd.run:
    - name: {{ git_ssh }} git clone {{ data['source']['url'] }} {{ s.templates.target }}/{{ name }}
    - unless: test -d {{ s.templates.target }}/{{ name }}
    - user: {{ s.user }}

{{ name }}_fetch_all:
  cmd.run:
    - name: {{ git_ssh }} git fetch origin --prune
    - cwd: {{ s.templates.target }}/{{ name }}
    - user: {{ s.user }}

{{ name }}_update_to_latest:
  cmd.run:
    - name: git checkout -f {{ br_requested }} && git reset --hard origin/{{ br_requested }}
    - cwd: {{ s.templates.target }}/{{ name }}
    - user: {{ s.user }}

  {% if data['source']['submodules']|d(false) %}
{{ name }}_submodules_update:
  cmd.run:
    - name: {{ git_ssh }} git submodule update --init --recursive
    - cwd: {{ s.templates.target }}/{{ name }}
    - user: {{ s.user }}
  {% endif %}

{% endif %}

{% endmacro %}


{% macro dokku_hostname(name, data) %}
{% if data['hostname'] is defined %}
{#
hostname: 'host.domain.com'
#}
  {{ dokku("docker-options:add", name, "deploy,run '-h "+ data['hostname']+ "'") }}
{% endif %}
{% endmacro %}


{% macro dokku_docker_opts(name, data) %}
{% if data['docker-opts'] is defined %}
{#
docker-opts:
  [-] "deploy,run": '-h host.domain.com'

#}
  {% if data['docker-opts'] is mapping %}
    {% for phase, opts in data['docker-opts'].iteritems() %}
      {{ dokku("docker-options:add", name, phase+ " '"+ opts+ "'") }}
    {% endfor %}
  {% else %}
    {% for optline in data['docker-opts'] %}
      {% for phase, opts in optline.iteritems() %}
        {{ dokku("docker-options:add", name, phase+ " '"+ opts+ "'") }}
      {% endfor %}
    {% endfor %}
  {% endif %}

{% endif %}
{% endmacro %}


{% macro dokku_certs(name, data) %}
{% if data['certs'] is defined %}
{#
certs:
  certificate: ["selfsigned", "letsencrypt", certificate-data]
  key: none
[vhost: x.y.z]

# we generate a selfsigned certificate first (even if set to letsencrypt)
# so we fool dokku for SSL_IN_USE
#}
  {% if data['certs']['certificate'] in ('selfsigned', 'letsencrypt') %}
    {% if data['vhost'] is defined %}
        {% set hostname= data['vhost'] %}
    {% else %}
        {% set hostname= name+"."+ s.vhost %}
    {% endif %}
{% load_yaml as cert_input %}
stdout: |
  AT
  {{ salt['pillar.get']('timezone_short') }}
  {{ salt['pillar.get']('timezone_short') }}
  {{ salt['pillar.get']('extdomain') }}
  security
  {{ hostname }}
  {{ s.letsencrypt.email }}


  .

{% endload %}
{{ dokku_pipe(cert_input.stdout, "certs:generate", name+ " "+ hostname) }}
    {% if data['certs']['certificate'] == 'letsencrypt' %}

dokku_delete_nginx_conf_{{ name }}:
  file.absent:
    - name: /home/{{ s.user }}/{{ name }}/nginx.conf

{{ dokku("nginx:build-config", name) }}

dokku_create_urls_{{ name }}:
  cmd.run:
    - name: echo "https://{{ name }}.{{ s.vhost }}" > /home/dokku/{{ name }}/URLS
    - unless: test -f /home/dokku/{{ name }}/URLS
    - user: {{ s.user }}

dokku_set_{{ name }}_LETSENCRYPT_EMAIL:
  cmd.run:
    - name: 'dokku config:set --no-restart {{ name }} DOKKU_LETSENCRYPT_EMAIL={{ s.letsencrypt.email }}'
    - unless: 'dokku config {{ name }} | grep -q "DOKKU_LETSENCRYPT_EMAIL: {{ s.letsencrypt.email }}"'

dokku_set_{{ name }}_LETSENCRYPT_SERVER:
  cmd.run:
    - name: 'dokku config:set --no-restart {{ name }} DOKKU_LETSENCRYPT_SERVER={{ s.letsencrypt.target }}'
    - unless: 'dokku config {{ name }} | grep -q "DOKKU_LETSENCRYPT_SERVER:"'

    {{ dokku("letsencrypt", name) }}
    {% endif %}
  {% else %}
{{ dokku_pipe(data['certs']['certificate']+ "\n"+ data['certs']['key'], "certs:add", name) }}
  {% endif %}
{% endif %}
{% endmacro %}


{% macro dokku_env(name, data) %}
{% if data['env'] is defined %}
{#
env:
  envname: setting

#}
  {% for ename, edata in data['env'].iteritems() %}
dokku_config_set_{{ name }}_{{ ename }}:
  cmd.run:
    - name: |
        dokku config:set --no-restart {{ name }} {{ ename }}={{ salt['extutils.quote'](edata)|indent(8, False) }}

  {% endfor %}

{% endif %}
{% endmacro %}

{% macro dokku_volumes(name, data) %}
{% if data['volumes'] is defined %}
{#
volumes:
  data_container_name: /mount_point/1

#}
  {% for vname, vdata in data['volumes'].iteritems()  %}
    {% set vpathlist=[vdata,] if vdata is string else vdata %}
    {% for vpath in vpathlist %}
      {% set vreal=vpath|list|first if vpath is mapping else vpath %}
      {% set datadir= salt['file.normpath'](s.persistent_data+ "/"+ vname+ "/"+ vreal) %}
      {% set vopt= ":"+ vpath['options'] if vpath['options'] is defined else '' %}

"makedir_{{ datadir }}":
  file.directory:
    - name: {{ datadir }}
    - user: 1000
    - group: 1000
    - dir_mode: 775
    - file_mode: 664
    - makedirs: true

{{ dokku("docker-options:add", name, "deploy,run '-v "+ datadir+ ":"+ vreal+ vopt+  "'") }}
    {% endfor %}
  {% endfor %}
{% endif %}
{% endmacro %}


{% macro dokku_database(name, data) %}
{% if data['database'] is defined %}
{#
database:
  mariadb: databasecontainername
  [mariadb:]
    - first_database
    - second_database
  postgresql: databasecontainername
  [postgresql:]
    - first_database
    - second_database
#}
  {% for dbtype, dbname in data['database'].iteritems() %}
    {% if dbtype in ['couchdb', 'elasticsearch', 'mariadb', 'memcached', 'mongo', 'postgres', 'rabbitmq', 'redis', 'rethinkdb' ] %}
      {% set dblist=[dbname,] if dbname is string else dbname %}
      {% for singledb in dblist %}
        {% set dbservice= "dokku."+ dbtype+ "."+ singledb %}
        {% set dbalias= salt['cmd.run_stdout']('echo "'+ dbservice+ '" | tr ._ -', python_shell=True) %}
{{ dokku(dbtype+ ":create", singledb) }}
{{ dokku(dbtype+ ":link", singledb, name) }}
{{ dokku("docker-options:remove", name, "build '--link "+ dbservice+ ":"+ dbalias+ "'") }}
      {% endfor %}
    {% endif %}
  {% endfor %}
{% endif %}
{% endmacro %}


{% macro dokku_files(name, data, files_touched) %}
{% if data['files'] is defined %}
{#
files:
  content:
    /Procfile: |
        web: RAILS_ENV=${RACK_ENV:-production} rake db:migrate && bundle exec puma -t 5:5 -p ${PORT:-8080} -e ${RAILS_ENV}
    /config/database.yml: |
        production:
          url: <%= ENV['DATABASE_URL'] %>
  append:
    /Gemfile: |
        gem "pg", group: :postgres
        gem "rails_12factor", group: :production
        gem "puma", group: :production
  comment:
    .gitignore: ^(config/site.yml)|(config/database.yml)
  templates:
    /config/site.yml: "salt://roles/imgbuilder/extra/dokku-definitions/tracks/site.yml"
#}

{% if data['files']['content'] is defined %}
  {% for fname, fcontent in data['files']['content'].iteritems() %}
  {% do files_touched.append(fname) %}
content_{{ s.templates.target }}/{{ name }}/{{ fname }}:
  file.managed:
    - name: {{ s.templates.target }}/{{ name }}/{{ fname }}
    - contents: |
{{ fcontent|indent(8, true) }}
    - user: {{ s.user }}
    - makedirs: true
  {% endfor %}
{% endif %}

{% if data['files']['append'] is defined %}
  {% for fname, fappend in data['files']['append'].iteritems() %}
  {% do files_touched.append(fname) %}
append_{{ s.templates.target }}/{{ name }}/{{ fname }}:
  file.append:
    - name: {{ s.templates.target }}/{{ name }}/{{ fname }}
    - text: |
{{ fappend|indent(8, true) }}
  {% endfor %}
{% endif %}

{% if data['files']['replace'] is defined %}
  {% for fname, freplace in data['files']['replace'].iteritems() %}
    {% do files_touched.append(fname) %}
    {% for pname, pdata in freplace.iteritems() %}
replace_{{ s.templates.target }}/{{ name }}/{{ fname }}_{{ pname }}:
  file.replace:
    - name: {{ s.templates.target }}/{{ name }}/{{ fname }}
    - backup: false
{%- if pdata['flags'] is defined %}
    - flags: {{ pdata['flags'] }}
{%- endif %}
    - pattern: |
{{ pdata['pattern']|indent(8, true) }}
    - repl: |
{{ pdata['repl']|indent(8, true) }}
    {% endfor %}
  {% endfor %}
{% endif %}

{% for a in ['comment', 'uncomment'] %}
  {% if data['files'][a] is defined %}
    {% for fname, fregex in data['files'][a].iteritems() %}
    {% do files_touched.append(fname) %}
{{ a }}_{{ s.templates.target }}/{{ name }}/{{ fname }}:
  file.{{ a }}:
    - name: {{ s.templates.target }}/{{ name }}/{{ fname }}
    - regex: {{ fregex }}
    - backup: ''
    {% endfor %}
  {% endif %}
{% endfor %}

{% if data['files']['templates'] is defined %}
  {% for fname, fdata in data['files']['templates'].iteritems() %}
    {% set fsource= fdata['source'] %}
    {% do files_touched.append(fname) %}
managed_{{ s.templates.target }}/{{ name }}/{{ fname }}:
  file.managed:
    - name: {{ s.templates.target }}/{{ name }}/{{ fname }}
    - source: {{ fsource }}
    - user: {{ s.user }}
    - makedirs: true
    - template: jinja
    {% if fdata['context'] is defined %}
    - context:
{% for c, d in fdata['context'].iteritems() %}        {{ c }}: "{{ d }}"
{% endfor %}
    {% endif %}
  {% endfor %}
{% endif %}

{% endif %}
{% endmacro %}


{% macro dokku_nginx(name, data) %}
{#
nginx:
  upload.conf: |
      client_max_body_size 50M;
#}
{% if data['nginx'] is defined %}
  {% for fname, fcontent in data['nginx'].iteritems() %}
/home/{{ s.user }}/{{ name }}/nginx.conf.d/{{ fname }}:
  file.managed:
    - contents: |
{{ fcontent|indent(8, true) }}
    - user: {{ s.user }}
    - makedirs: true
  {% endfor %}
{% endif %}
{% endmacro %}


{% macro dokku_scale(name, data) %}
{#
scale:
  web: 1
  worker: 1
#}
{% if data['scale'] is defined %}
  {% set t=[] %}
  {% for proc, count in data['scale'].iteritems() %}
      {% do t.append(proc+ '='+ count|string) %}
  {% endfor %}
  {% set newscale= t|sort %}
  {% set oldscale= salt['cmd.run_stdout']('dokku ps:scale nextecs | grep -E ".*[0-9]+" | sed -re "s/[> \t-]+([^\t ]+)[\t ]+([0-9]+).*/\\1=\\2/g"', python_shell=true).split()|sort %}
  {% if newscale != oldscale %}
    {{ dokku("ps:scale", name, newscale|join(' ')) }}
  {% endif %}
{% endif %}
{% endmacro %}


{% macro dokku_pre_commit(name, data) %}
{% if data['pre_commit'] is defined %}
  {% for fname in data['pre_commit'] %}
pre_commit_{{ fname }}:
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: {{ fname }}
    - user: {{ s.user }}
  {% endfor %}
{% endif %}
{% endmacro %}


{% macro dokku_git_commit(name, data, files_touched) %}

git_add_user_{{ name }}:
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: git config user.email "saltmaster@localhost" && git config user.name "Salt Master"
    - user: {{ s.user }}

{% if files_touched != [] %}
git_add_and_commit_{{ name }}:
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: git add {{ files_touched|join(' ') }} && git commit -a -m "modified by salt, based on rev {{ data['rev']|d('master') }}"
    - user: {{ s.user }}
{% endif %}

{% endmacro %}


{% macro dokku_git_add_remote(name) %}

git_add_remote_{{ name }}:
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: git remote add dokku dokku@omoikane.ep3.at:{{ name }}
    - user: {{ s.user }}

{% endmacro %}


{% macro dokku_git_push(name, data) %}
{% set ourbranch=data['source']['branch']|d('master') %}

push_{{ name }}_{{ ourbranch }}:
  cmd.run:
    - cwd: {{ s.templates.target }}/{{ name }}
    - name: git push -f --set-upstream dokku {{ ourbranch }}:{{ ourbranch }}

{% endmacro %}


{% macro dokku_post_commit(name, data) %}
{% if data['post_commit'] is defined %}
  {% for fname in data['post_commit'] %}
{{ dokku("run", name, fname) }}
  {% endfor %}
{% endif %}
{% endmacro %}


{% macro create_container(name, orgdata, only_prepare=False) %}
{#
name: name of container
orgdata: loaded yml dict or filenamestring to
#}

{% if orgdata is string %}
{% import_yaml orgdata as data with context %}
{% else %}
{% set data=orgdata %}
{% endif %}

{% set files_touched=[] %}

{{ dokku_checkout(name, data) }}
{{ dokku("apps:create", name) }}
{{ dokku_hostname(name, data) }}
{{ dokku_docker_opts(name, data) }}
{{ dokku_volumes(name, data) }}
{{ dokku_database(name, data) }}
{{ dokku_env(name, data) }}
{{ dokku_certs(name, data) }}
{{ dokku_files(name, data, files_touched) }}
{{ dokku_pre_commit(name, data) }}
{{ dokku_git_commit(name, data, files_touched) }}
{{ dokku_git_add_remote(name) }}
{{ dokku_nginx(name, data) }}
{{ dokku_scale(name, data) }}

{{ dokku("config", name) }}
{{ dokku("docker-options", name) }}

{% if not only_prepare %}
  {{ dokku_git_push(name, data) }}
  {{ dokku_post_commit(name, data) }}
{% endif %}

{% endmacro %}



{% macro destroy_container(name, orgdata) %}

{% if orgdata is string %}
{% import_yaml orgdata as data with context %}
{% else %}
{% set data=orgdata %}
{% endif %}

{{ dokku("disable", name) }}

{% if data['volumes'] is defined %}
  {% for vname, vdata in data['volumes'].iteritems()  %}
    {% set vpathlist=[vdata,] if vdata is string else vdata %}
    {% for vpath in vpathlist %}
      {% set vreal=vpath|list|first if vpath is mapping else vpath %}
      {% set datadir= salt['file.normpath'](s.persistent_data+ "/"+ vname+ "/"+ vreal) %}
      {% set vopt= ":"+ vpath['options'] if vpath['options'] is defined else '' %}
{{ dokku("docker-options:remove", name, "deploy,run '-v "+ datadir+ ":"+ vreal+ vopt+ "'") }}
{# do not destroy data, just unlink from container #}
    {% endfor %}
  {% endfor %}
{% endif %}

{% if data['database'] is defined %}
  {% for dbtype, dbname in data['database'].iteritems() %}
    {% if dbtype in ['couchdb', 'elasticsearch', 'mariadb', 'memcached', 'mongo', 'postgres', 'rabbitmq', 'redis', 'rethinkdb' ] %}
      {% if dbname is string %}
{{ dokku(dbtype+ ":unlink", name, dbname) }}
{# do not destroy database container, just unlink
  {{ dokku_pipe(dbname, dbtype+ ":destroy", dbname) }}
#}
      {% else %}
        {% for singledb in dbname %}
{{ dokku(dbtype+ ":unlink", name, singledb) }}
{# do not destroy database container, just unlink
  {{ dokku_pipe(singledb, dbtype+ ":destroy", singledb) }}
#}
        {% endfor %}
      {% endif %}
    {% endif %}
  {% endfor %}
{% endif %}

{{ dokku_pipe(name, "apps:destroy", name) }}

{{ name }}_delete:
  file.absent:
    - name: {{ s.templates.target }}/{{ name }}

{% endmacro %}
