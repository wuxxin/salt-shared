{% from "server/gitea/defaults.jinja" import settings with context %}

include:
  - development.git

gitea_requisites:
  pkg.installed:
    - pkgs:
      - gnupg
      - xz-utils
    - require:
      - sls: development.git

{% set gitea_local_binary = "/usr/local/bin/gitea" %}

gitea_archive:
  file.managed:
    - source: {{ settings.external.gitea_binary_xz.download }}
    - source_hash: {{ settings.external.gitea_binary_xz.hash_url }}
    - name: {{ settings.external.gitea_binary_xz.target }}

gitea_binary:
  cmd.wait:
    - name: xz -d < {{ settings.external.gitea_binary_xz.target }} > {{ gitea_local_binary }} && chmod +x {{ gitea_local_binary }}
    - onchanges:
      - file: gitea_archive
    - require:
      - pkg: gitea_requisites

{% for entry in settings.profile %}

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
    - source: salt://server/gitea/app.ini.jinja
    - name: {{ entry.salt.home_dir }}/gitea_{{ entry.name }}_app.ini
    - mode: "0640"
    - user: {{ entry.global.run_user }}
    - group: {{ entry.global.run_user }}
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
    - source: salt://server/gitea/gitea.service
    - name: /etc/systemd/system/gitea_{{ entry.name }}.service
    - template: jinja
    - defaults:
        entry: {{ entry }}
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
