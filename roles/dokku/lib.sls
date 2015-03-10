# dokku support
###############


{% macro dokku(command, param1, param2) %}
"{{ command }}_{{ param1 }}_{{ param2 }}:
  cmd.run:
    - name: dokku {{ command }} {{ param1 }} {{ param2 }}

{% endmacro %}


{% macro dokku_pipe(pipedata, command, param1) %}
"{{ command }}_{{ param1 }}:
  cmd.run:
    - name: echo -e '{{ pipedata }}' | dokku {{ command }} {{ param1 }}

{% endmacro %}


{% macro create_container(name, data) %}

{#
source: url
branch: branchname
#}

.) make a workdir
.) checkout data['source'] branch data['branch'] to workdir
{% if data['branch'] is defined %}{% endif %}
{{ dokku("create",name) }}


{% if data['volume'] is defined %}
{#
volume:
  data_container_name:
    - /mount_point/1
    - /opt/mount_point/2
#}

  {% for cname, cpaths in data['volume'].iteritems() %}
{{ dokku("volume:create", cname, cpaths.join(',')) }}
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
    {% if dbtype in ['postgresql', 'mariadb', 'mongodb', 'elasticsearch' ] %}
{{ dokku(dbtype+ ":create", dbname) }}
{{ dokku(dbtype+ ":link", name, dbname) }}
    {% endif %}
    {% if dbtype in ['memcached', 'redis'] %}
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
  {{ dokku("config:set", name, newenv.join(' ')) }}
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
  templates:
    /config/site.yml: "salt://roles/imgbuilder/extra/dokku-definitions/tracks/site.yml"
#}

{% if data['files']['content'] is defined %}
  {% for fname, fcontent in data['files']['content'].iteritems() %}
{{ workdir }}/fname:
  file.managed:
    - content: |
{{ fcontent }}.ident(8, true)
  {% endfor %}
{% endif %}

{% if data['files']['append'] is defined %}
  {% for fname, fappend in data['files']['append'].iteritems() %}
{{ workdir }}/fname:
  file.append:
    - content: |
{{ fappend }}.ident(8, true)
  {% endfor %}
{% endif %}

{% if data['files']['templates'] is defined %}
  {% for fname, fsource in data['files']['append'].iteritems() %}
{{ workdir }}/fname:
  file.managed:
    - source: {{ fsource }}
  {% endfor %}
{% endif %}


git_add_remote_{{ name }}_{{ branch }}:
  cmd.run:
    - cwd: {{ workdir }}
    - name: git remote add dokku dokku@omoikane.ep3.at:{{ name }}

{% set ourbranch='master' %}
{% if data['branch'] is defined %}
{% set ourbranch=data['branch'] %}
{% endif %}

push_{{ name }}_{{ branch }}:
  cmd.run:
    - cwd: {{ workdir }}
    - name: git push dokku {{ ourbranch }}:master

{% endmacro %}


{% macro destroy_container(data) %}

{% endmacro %}


