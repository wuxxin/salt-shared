{% from "roles/dokku/defaults.jinja" import settings as s with context %}
include:
  - .ppa
  - nginx
  - roles.docker

{# fixme: dokku storage relocate makes quirks #}
{# fixme: dokku installer gets stuck as process on install #}
{# fixme: plugin install fails on second install #}

{% if salt['pillar.get']('dokku:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('dokku:custom_storage')) }}
{% endif %}

dokku:
  debconf.set:
    - name: dokku
    - data:
        'dokku/web_config': { 'type': 'boolean', 'value': 'false' }
        'dokku/vhost_enable': { 'type': 'boolean', 'value': 'true' }
        'dokku/hostname': {'type': 'string', 'value': '{{ s.hostname }}' }
  pkg.installed:
    - name: dokku
    - require:
      - debconf: dokku
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
      - cmd: dokku_ppa
{% endif %}
      - sls: roles.docker
      - sls: nginx

dokku_core_dependencies:
  cmd.wait:
    - name: dokku plugin:install-dependencies --core
    - watch:
      - pkg: dokku

"dokku_makedir_{{ s.templates.target }}":
  file.directory:
    - name: {{ s.templates.target }}
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 775
    - makedirs: True
    - require:
      - pkg: dokku

{% if pillar['adminkeys_present']|d(False) %}
{% for adminkey in pillar['adminkeys_present'] %}
"dokku_access_add_{{ adminkey }}":
  cmd.run:
    - name: echo "{{ adminkey }}" | sshcommand acl-add dokku admin
    - require:
      - cmd: dokku_core_dependencies
{% endfor %}
{% endif %}

{% set plugin_list=[
('dokku-couchdb','https://github.com/dokku/dokku-couchdb.git'),
('dokku-elasticsearch','https://github.com/dokku/dokku-elasticsearch.git'),
('dokku-mariadb','https://github.com/dokku/dokku-mariadb.git'),
('dokku-memcached','https://github.com/dokku/dokku-memcached.git'),
('dokku-mongo','https://github.com/dokku/dokku-mongo.git'),
('dokku-postgres','https://github.com/dokku/dokku-postgres.git'),
('dokku-rabbitmq','https://github.com/dokku/dokku-rabbitmq.git'),
('dokku-redis', 'https://github.com/dokku/dokku-redis.git'),
('dokku-rethinkdb', 'https://github.com/dokku/dokku-rethinkdb.git'),
('dokku-maintenance', 'https://github.com/dokku/dokku-maintenance.git'),
('dokku-redirect', 'https://github.com/dokku/dokku-redirect.git'),

('dokku-apt', 'https://github.com/F4-Group/dokku-apt'),
('dokku-app-predeploy-tasks', 'https://github.com/michaelshobbs/dokku-app-predeploy-tasks.git'),
('dokku-secure-apps', 'https://github.com/matto1990/dokku-secure-apps.git'),
('dokku-git-rev', 'https://github.com/cjblomqvist/dokku-git-rev.git'),
('dokku-acl','https://github.com/mlebkowski/dokku-acl.git'),
('dokku-forego', 'https://github.com/Flink/dokku-forego.git'),

] %}

{# for testing, not tested so far
https://github.com/dokku/dokku-nats
https://github.com/dokku/dokku-redirect
https://github.com/sgulseth/dokku-letsencrypt
https://github.com/ignlg/dokku-builders-plugin
https://github.com/Flink/dokku-docker-auto-volumes
https://github.com/dokku/dokku-graphite-grafana
#}
{# tested but not working, or not right for us
('dokku-http-auth', 'https://github.com/dokku/dokku-http-auth.git'),
('dokku-webhooks', 'https://github.com/nickstenning/dokku-webhooks.git'),
('dokku-docker-auto-volumes', 'https://github.com/Flink/dokku-docker-auto-volumes.git'),
('dokku-registry', 'https://github.com/agco/dokku-registry.git'),
('dokku-hostname', 'https://github.com/michaelshobbs/dokku-hostname.git'),
('dokku-logspout', 'https://github.com/michaelshobbs/dokku-logspout.git'),
#}

{% for (n,p) in plugin_list %}
install_dokku_plugin_{{ n }}:
  cmd.run:
    - name: dokku plugin:update {{ p }}
    - require:
      - cmd: dokku_core_dependencies
    - require_in:
      - cmd: dokku_plugin_prepare
{% endfor %}

dokku_plugin_prepare:
  cmd.run:
    - name: dokku plugin:install
    - require:
      - cmd: dokku_core_dependencies
