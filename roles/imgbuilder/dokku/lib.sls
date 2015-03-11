{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% set base= s.image_base+ "/templates/dokku" %}


{% macro dokku(command, param1, param2=None) %}
{% set opt_para="" if param2 == None else param2 %}
"{{ command }}_{{ param1 }}_{{ opt_para }}":
  cmd.run:
    - name: dokku {{ command }} {{ param1 }} {{ opt_para }}

{% endmacro %}


{% macro dokku_pipe(pipedata, command, param1) %}
"{{ command }}_{{ param1 }}":
  cmd.run:
    - name: echo -e '{{ pipedata }}' | dokku {{ command }} {{ param1 }}

{% endmacro %}


{% macro create_container(name, orgdata) %}

{#
orgdata: loaded yml dict or filenamestring to import_yaml 
data: loaded yml dict
---
source: url
branch: branchname
#}
{% if orgdata is string %}
{% import_yaml orgdata as data %}
{% else %}
{% set data=orgdata %}
{% endif %}

{{ name }}_checkout:
  git.latest:
    - name: {{ data['source'] }}
    - target: {{ base }}/{{ name }}
{% if data['branch'] is defined %}
    - rev: {{ data ['branch'] }}
{% endif %}
    - user: {{ s.user }} 

{{ dokku("create",name) }}


{% if data['volume'] is defined %}
{#
volume:
  data_container_name:
    - /mount_point/1
    - /opt/mount_point/2
#}

  {% for cname, cpaths in data['volume'].iteritems() %}
{{ dokku("volume:create", cname, cpaths|join(',')) }}
{{ dokku("volume:link", name, cname) }}
  {% endfor %}
{% endif %}


{% if data['database'] is defined %}
{#
database:
  mariadb: databasecontainername
  postgresql: databasecontainername
  redis: true
#}

  {% for dbtype, dbname in data['database'].iteritems() %}
    {% if dbtype in ['postgresql', 'mariadb', 'mongodb', 'elasticsearch', 'memcached' ] %}
{{ dokku(dbtype+ ":create", dbname) }}
{{ dokku(dbtype+ ":link", name, dbname) }}
    {% endif %}
    {% if dbtype in ['redis'] %}
{{ dokku(dbtype+ ":create", name) }}
    {% endif %}
  {% endfor %}
{% endif %}


{% if data['env'] is defined %}
{#
env:
  envname: setting
  DOKKU_VERBOSE_DATABASE_ENV: "true"
#}

  {% set newenv=[] %}
  {% for ename, edata in data['env'].iteritems() %}
  {% do newenv.append(ename+'='+edata) %}
  {% endfor %}
  {{ dokku("config:set", name, newenv|join(' ')) }}
{% endif %}


{% if data['ssl'] is defined %}
{#
ssl:
  certificate: selfsigned
  key: none
#}

  {% if data['ssl']['certificate'] == 'selfsigned' %}
{{ dokku("ssl:selfsigned", name) }}
  {% else %}
{{ dokku_pipe(data['ssl']['certificate'], "ssl:certificate", name) }}
{{ dokku_pipe(data['ssl']['key'], "ssl:key", name) }}
  {% endif %}
{% endif %}


{% if data['docker-opts'] is defined %}
{#
docker-opts: '-h host.domain.com'
#}

  {{ dokku("docker-options:add", name, data['docker-opts']) }}
{% endif %}


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

{% set files_touched=[] %}

{% if data['files']['content'] is defined %}
  {% for fname, fcontent in data['files']['content'].iteritems() %}
  {% do files_touched.append(fname) %}
content_{{ base }}/{{ name }}/{{ fname }}:
  file.managed:
    - name: {{ base }}/{{ name }}/{{ fname }}
    - contents: |
{{ fcontent|indent(8, true) }}
    - user: {{ s.user }} 
  {% endfor %}
{% endif %}

{% if data['files']['append'] is defined %}
  {% for fname, fappend in data['files']['append'].iteritems() %}
  {% do files_touched.append(fname) %}
append_{{ base }}/{{ name }}/{{ fname }}:
  file.append:
    - name: {{ base }}/{{ name }}/{{ fname }}
    - text: |
{{ fappend|indent(8, true) }}
    - user: {{ s.user }} 
  {% endfor %}
{% endif %}

{% if data['files']['comment'] is defined %}
  {% for fname, fregex in data['files']['comment'].iteritems() %}
  {% do files_touched.append(fname) %}
comment_{{ base }}/{{ name }}/{{ fname }}:
  file.comment:
    - name: {{ base }}/{{ name }}/{{ fname }}
    - regex: {{ fregex }}
    - user: {{ s.user }} 
  {% endfor %}
{% endif %}

{% if data['files']['templates'] is defined %}
  {% for fname, fsource in data['files']['templates'].iteritems() %}
  {% do files_touched.append(fname) %}
managed_{{ base }}/{{ name }}/{{ fname }}:
  file.managed:
    - name: {{ base }}/{{ name }}/{{ fname }}
    - source: {{ fsource }}
    - user: {{ s.user }} 
  {% endfor %}
{% endif %}

{% endif %}


{% if data['pre_commit'] is defined %}
  {% for fname in data['pre_commit'] %}
pre_commit_{{ fname }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: {{ fname }}
    - user: {{ s.user }}
  {% endfor %}
{% endif %}


{% set ourbranch='master' %}
{% if data['branch'] is defined %}
{% set ourbranch=data['branch'] %}
{% endif %}

git_add_user_{{ name }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: git config user.email "saltmaster@localhost" && git config user.name "Salt Master"
    - user: {{ s.user }} 

git_add_and_commit_{{ name }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: git add {{ files_touched|join(' ') }} && git commit -a -m "modified by salt"
    - user: {{ s.user }} 

git_add_remote_{{ name }}_{{ ourbranch }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: git remote add dokku dokku@omoikane.ep3.at:{{ name }}
    - user: {{ s.user }} 

{#
push_{{ name }}_{{ ourbranch }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: git push dokku {{ ourbranch }}:master
#}

{% endmacro %}


{% macro destroy_container(name) %}

{% endmacro %}


