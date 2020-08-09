{% from "gitea/defaults.jinja" import profile_defaults, external with context %}
{% set gitea_local_archive= "/usr/local/"+ external.gitea_binary_xz.target+ "/gitea.xz" %}
{% set gitea_local_binary = "/usr/local/bin/gitea" %}

include:
  - vcs.git

gitea_requisites:
  pkg.installed:
    - pkgs:
      - gnupg
      - xz-utils
    - require:
      - sls: vcs.git

gitea_archive:
  file.managed:
    - source: {{ external.gitea_binary_xz.download }}
    - source_hash: {{ external.gitea_binary_xz.hash_url }}
    - name: {{ gitea_local_archive }}
gitea_binary:
  cmd.run:
    - name: xz -d < {{ gitea_local_archive }} > {{ gitea_local_binary }} && chmod +x {{ gitea_local_binary }}
    - onchange:
      - file: gitea_archive
    - require:
      - pkg: gitea_requisites

{% for raw_entry in salt['pillar.get']('gitea:profile', []) %}

  {% set entry=salt['grains.filter_by']({'default': profile_defaults},
    grain='default', default= 'default', merge= raw_entry) %}
  {% if entry.global.run_user is not defined %}
    {% do entry.global.update({ 'run_user': 'gitea_' ~ entry.name }) %}
  {% endif %}
  {% if entry.salt.home_dir is not defined %}
    {% do entry.salt.update({ 'home_dir': '/home/' ~ entry.global.run_user }) %}
  {% endif %}
  {% if entry.repository.root is not defined %}
    {% do entry.repository.update({ 'root': entry.salt.home_dir ~ '/repos' }) %}
  {% endif %}
  {% if entry.salt.custom_dir is not defined %}
    {% do entry.salt.update({ 'custom_dir': entry.salt.home_dir ~ '/custom' }) %}
  {% endif %}
  {% if entry.salt.work_dir is not defined %}
    {% do entry.salt.update({ 'work_dir': entry.salt.home_dir ~ '/work' }) %}
  {% endif %}
  {% if entry.oauth2.jwt_secret is not defined %}
    {% do entry.oauth2.update({ 'enable': 'false'}) %}
  {% endif %}
  {% if entry.server.lfs_jwt_secret is not defined %}
    {% do entry.server.update({ 'lfs_start_server': 'false'}) %}
  {% endif %}
  {% if entry.server.http_addr is not defined %}
    {% if entry.server.protocol == 'http' %}
      {% do entry.server.update({ 'http_addr': '127.0.0.1'}) %}
    {% elif entry.server.protocol == 'unix' %}
      {% do entry.server.update({ 'http_addr': '/run/' ~ entry.global.run_user ~ '/gitea.sock'}) %}
    {% endif %}
  {% endif %}

account_{{ entry.global.run_user }}:
  group.present:
    - name: {{ entry.global.run_user }}
  user.present:
    - name: {{ entry.global.run_user }}
    - gid: {{ entry.global.run_user }}
    - home: {{ entry.salt.home_dir }}
    - remove_groups: False
    - require:
      - group: account_{{ entry.global.run_user }}

gitea_home_dir_{{ entry.name }}:
  file.directory:
    - name: {{ entry.salt.home_dir }}
    - require:
      - user: account_{{ entry.global.run_user }}

  {% for i in ['.ssh', '.gnupg'] %}
gitea_{{ i }}_dir_{{ entry.name }}:
  file.directory:
    - name: {{ entry.salt.home_dir }}/{{ i }}
    - mode: "0700"
    - user: {{ entry.global.run_user }}
    - group: {{ entry.global.run_user }}
    - require:
      - file: gitea_home_dir_{{ entry.name }}
  {% endfor %}

gitea_custom_dir_{{ entry.name }}:
  file.directory:
      - name: {{ entry.salt.custom_dir }}

gitea_work_dir_{{ entry.name }}:
  file.directory:
      - name: {{ entry.salt.work_dir }}
      - mode: "0750"
      - user: {{ entry.global.run_user }}
      - group: {{ entry.global.run_user }}

gitea_repository_root_{{ entry.name }}:
  file.directory:
      - name: {{ entry.repository.root }}
      - mode: "0750"
      - user: {{ entry.global.run_user }}
      - group: {{ entry.global.run_user }}

  {% if entry.gpg.key %}
gitea_ggp_user_{{ entry.name }}:
  cmd.run:
    - name: create gitea gpg user
    - unless: gpg already created
    - require:
      - file: {{ entry.salt.home_dir }}/.gnupg
    - require_in:
      - service: gitea_{{ entry.name }}.service
  {% endif %}

gitea_{{ entry.name }}_app.ini:
  file.managed:
    - source: salt://gitea/app.ini.jinja
    - name: /etc/gitea_{{ entry.name }}_app.ini
    - template: jinja
    - defaults:
        entry: {{ entry }}
    - require:
      - file: gitea_home_dir_{{ entry.name }}
      - file: gitea_.ssh_dir_{{ entry.name }}
      - file: gitea_.gnupg_dir_{{ entry.name }}
      - file: gitea_custom_dir_{{ entry.name }}
      - file: gitea_work_dir_{{ entry.name }}
      - file: gitea_repository_root_{{ entry.name }}

gitea_{{ entry.name }}.service:
  file.managed:
    - source: salt://gitea/gitea.service
    - name: /etc/systemd/system/gitea_{{ entry.name }}.service
    - template: jinja
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: gitea_{{ entry.name }}.service
  service.running:
    - enable: true
    - require:
      - cmd: gitea_binary
      - user: gitea_{{ entry.name }}
    - watch:
      - file: gitea_{{ entry.name }}.service
      - file: gitea_{{ entry.name }}_app.ini

{% endfor %}
