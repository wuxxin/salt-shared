{% from "oauth2proxy/defaults.jinja" import settings with context %}
{% set local_binary = "/usr/local/bin/oauth2-proxy" %}
{% set external = settings.external.oauth2_proxy_tar_gz %}

oauth2proxy_archive:
  file.managed:
    - source: {{ external.download }}
    - source_hash: sha256={{ external.hash }}
    - name: {{ external.target }}
  archive.extracted:
    - source: {{ external.target }}
    - name: /usr/local/bin
    - archive_format: tar
    - enforce_toplevel: false
    - overwrite: true
    - options: --strip-components 1 --wildcards "*/oauth2-proxy"
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

oauth2proxy_config_directory:
  file.directory:
    - name: /etc/oauth2proxy
    - mode: "750"
    - group: {{ settings.username }}

oauth2proxy@.service:
  file.managed:
    - source: salt://oauth2proxy/oauth2proxy@.service
    - name: /etc/systemd/system/oauth2proxy@.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: home_dir_{{ settings.username }}
      - file: oauth2proxy_config_directory
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - file: oauth2proxy@.service
    - onchanges:
      - file: oauth2proxy@.service

{% for entry in settings.profile %}

oauth2proxy_{{ entry.name }}.cfg:
  file:
  {%- if entry.enabled %}
    - managed
    - mode: "0640"
    - user: {{ settings.username }}
    - group: {{ settings.username }}
    - contents: |
        ## OAuth2 Proxy Config File
        ## https://github.com/oauth2-proxy/oauth2-proxy
    {%- for key,value in entry.config.items() %}
      {%- if value is string %}{%- set value = '"' ~ value ~ '"' %}{% endif %}
        {{ key|upper }} = {{ value }}
    {%- endfor %}
  {%- else %}
    - absent
  {%- endif %}
    - name: /etc/oauth2proxy/oauth2proxy_{{ entry.name }}.cfg
    - require:
      - file: oauth2proxy_config_directory

oauth2proxy@{{ entry.name }}.service:
  {%- if entry.enabled %}
  service.running:
    - enable: true
  {%- else %}
  service.dead:
    - enable: false
  {%- endif %}
    - require:
      - cmd: oauth2proxy_binary
      - cmd: oauth2proxy@.service
      - file: oauth2proxy_{{ entry.name }}.cfg
    - watch:
      - file: oauth2proxy_{{ entry.name }}.cfg
{% endfor %}
