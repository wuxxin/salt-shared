include:
  - .ppa
  - ruby
  - nginx
  - roles.docker

ruby-sinatra:
  pkg:
    - installed

dokku-alt:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: dokku-alt_ppa
      - pkg: docker
      - pkg: nginx
      - cmd: default-ruby
      - pkg: ruby-sinatra

{% endif %}
  service.running:
    - name: dokku-daemon
    - require:
      - pkg: dokku-alt

create_dokkurc:
  file.touch:
    - name: /home/dokku/dokkurc
    - require:
      - pkg: dokku-alt

/home/dokku/dokkurc:
  file.blockreplace:
    - marker_start: "# SALT - automatic config - begin"
    - marker_end: "# SALT - automatic config - end"
    - append_if_not_found: True
    - content: |
        export POSTGRESQL_IMAGE="ayufan/dokku-alt-postgresql:9.3"
    - user: dokku
    - require: 
      - file: create_dokkurc
    - watch_in:
      - service: dokku-alt

{% if pillar['adminkeys_present']|d(False) %}
{% for adminkey in pillar['adminkeys_present'] %}
dokku_access_add_{{ adminkey }}:
  cmd.run:
    - name: echo "{{ adminkey }}" | dokku access:add
{% endfor %}
{% endif %}

{% set plugin_list=[
('dokku-rethinkdb-plugin', 'https://github.com/stuartpb/dokku-rethinkdb-plugin.git'),
('dokku-elasticsearch-plugin', 'https://github.com/jezdez/dokku-elasticsearch-plugin.git'),
('dokku-alt-memcached', 'https://github.com/maccman/dokku-alt-memcached'),
('dokku-docker-options', 'https://github.com/dyson/dokku-docker-options.git'),
('dokku-timezone-plugin', 'https://github.com/udzura/dokku-timezone-plugin'),
('dokku-apt', 'https://github.com/F4-Group/dokku-apt.git'),
('dokku-jenkins', 'https://github.com/alessio/dokku-jenkins'),
('dokku-bash-completion', 'https://github.com/osv/dokku-bash-completion'),
] %}

{# ('dokku-django', 'https://github.com/mirmedia/dokku-django'), #}

{% for (n,p) in plugin_list %}
install_dokku_plugin_{{ n }}:
  git.latest:
    - name: {{ p }}
    - target: /var/lib/dokku-alt/plugins/{{ n }}

{% endfor %}
