{% from "oauth2proxy/defaults.jinja" import settings with context %}
{% set local_binary = "/usr/local/bin/oauth2-proxy" %}
{% set external = settings.external.oauth2_proxy_tar_gz %}

oauth2proxy_archive:
  file.managed:
    - source: {{ external.download }}
    - hash: {{ external.hash }}
    - name: {{ external.target }}
  archive.extracted:
    - source: {{ external.target }}
    - dest: {{ local_binary }}
    - onchanges:
      - file: oauth2proxy_archive

oauth2proxy_binary:
  cmd.run:
    - name: chmod +x {{ local_binary }}
    - onchanges:
      - archive: oauth2proxy_archive

user_{{ settings.username }}:
  group.present:
    - name: {{ settings.username }}
    - system: true
  user.present:
    - name: {{ settings.username }}
    - gid: {{ settings.username }}
    - home: {{ settings.home_dir }}
    - system: true
    - remove_groups: False
    - require:
      - group: user_{{ settings.username }}

home_dir_{{ settings.username }}:
  file.directory:
    - name: {{ settings.home_dir }}
    - user: {{ settings.username }}
    - group: {{ settings.username }}
    - mode: "770"
    - require:
      - user: user_{{ settings.username }}

oauth2proxy@.service:
  file.managed:
    - source: salt://oauth2proxy/oauth2proxy@.service
    - name: /etc/systemd/system/oauth2proxy@.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: home_dir_{{ settings.username }}

{% for entry in settings.profile %}

oauth2proxy_{{ entry.name }}.cfg:
  file.managed:
    - source: salt://oauth2proxy/oauth2proxy.defaults.cfg
    - name: {{ settings.home_dir }}/oauth2proxy_{{ entry.name }}.cfg
    - mode: "0640"
    - user: {{ settings.username }}
    - group: {{ settings.username }}
    - template: jinja
    - defaults:
        entry: {{ entry }}
    - require:
      - file: home_dir_{{ settings.username }}

oauth2proxy@{{ entry.name }}.service:
  file.managed:
    - name: /etc/systemd/system/oauth2proxy@{{ entry.name }}.service
    - template: jinja
    - defaults:
        entry: {{ entry }}
    - require:
      - file: oauth2proxy@.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: oauth2proxy@{{ entry.name }}.service
  service.running:
    - enable: true
    - require:
      - cmd: oauth2proxy_binary
      - file: oauth2proxy_{{ entry.name }}.cfg
      - file: oauth2proxy@{{ entry.name }}.service
    - watch:
      - file: oauth2proxy_{{ entry.name }}.cfg
      - file: oauth2proxy@{{ entry.name }}.service

{% endfor %}
