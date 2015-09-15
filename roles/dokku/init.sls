include:
  - .ppa
  - nginx
  - roles.docker

{% if salt['pillar.get']('dokku:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('dokku:custom_storage')) }}
{% endif %}

dokku:
  pkg.installed:
    - name: dokku
    - require:
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
      - cmd: dokku_ppa
{% endif %}
      - pkg: docker
      - pkg: nginx

  service.running:
    - name: dokku-daemon
    - require:
      - pkg: dokku

create_dokkurc:
  file.touch:
    - name: /home/dokku/dokkurc
    - require:
      - pkg: dokku

/home/dokku/dokkurc:
  file.blockreplace:
    - marker_start: "# SALT - automatic config - begin"
    - marker_end: "# SALT - automatic config - end"
    - append_if_not_found: True
    - content: |
        export DOKKU_VERBOSE_DATABASE_ENV=1
        export DOKKU_EXPOSED_PORTS="5000 8080 8000 80"
    - user: dokku
    - require:
      - file: create_dokkurc
    - watch_in:
      - service: dokku
{#
/home/dokku/VHOST:
/home/dokku/HOSTNAME:
#}

{% if pillar['adminkeys_present']|d(False) %}
{% for adminkey in pillar['adminkeys_present'] %}
dokku_access_add_{{ adminkey }}:
  cmd.run:
    - name: echo "{{ adminkey }}" | dokku access:add
{% endfor %}
{% endif %}

{% set plugin_list=[

('dokku-couchdb-multi-containers','https://github.com/Flink/dokku-couchdb-multi-containers.git'),
('dokku-elasticsearch','https://github.com/dokku/dokku-elasticsearch.git'),
('dokku-mariadb','https://github.com/dokku/dokku-mariadb.git'),
('dokku-memcached','https://github.com/dokku/dokku-memcached.git'),
('dokku-mongo','https://github.com/dokku/dokku-mongo.git'),
('dokku-postgres','https://github.com/dokku/dokku-postgres.git'),
('dokku-rabbitmq','https://github.com/dokku/dokku-rabbitmq.git'),
('dokku-redis','https://github.com/dokku/dokku-redis.git'),
('dokku-rethinkdb','https://github.com/dokku/dokku-rethinkdb.git'),

('dokku-http-auth','https://github.com/Flink/dokku-http-auth.git'),
('dokku-named-containers','https://github.com/Flink/dokku-named-containers.git'),
('dokku-forego','https://github.com/Flink/dokku-forego.git'),
('dokku-docker-auto-volumes','https://github.com/Flink/dokku-docker-auto-volumes.git'),
('dokku-airbrake-deploy','https://github.com/Flink/dokku-airbrake-deploy.git'),
('dokku-logspout','https://github.com/michaelshobbs/dokku-logspout.git'),
('dokku-maintenance','https://github.com/Flink/dokku-maintenance.git'),
] %}

{#
('','https://github.com/cjblomqvist/dokku-git-rev.git'),

#}

{% for (n,p) in plugin_list %}
install_dokku_plugin_{{ n }}:
  git.latest:
    - name: {{ p }}
    - target: /var/lib/dokku/plugins/{{ n }}
    - require_in:
      - cmd: dokku_plugins_install
{% endfor %}


dokku_plugins_install:
  cmd.run:
    - name: dokku plugins-install-dependencies && dokku plugins-install
    - require:
      - service: dokku
