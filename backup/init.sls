{% from "backup/defaults.jinja" import settings with context %}
{# set restic_cache= settings.home_dir ~ '/.cache/restic' #}

include:
  - backup.restic

{# always create default backup path, so backup completes in default config #}
{{ settings.default_test_repository }}:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - dir_mode: "700"

/usr/local/sbin/backup-restic.sh:
  file.managed:
    - source: salt://backup/backup-restic.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - mode: "0755"

/usr/local/lib/backup-service.sh:
  file.managed:
    - source: salt://backup/backup-service.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - mode: "0755"

/etc/systemd/system/backup.env:
  file.managed:
    - mode: "0600"
    - contents: |
        RESTIC_REPOSITORY={{ settings.repository_url }}
        RESTIC_PASSWORD={{ settings.repository_key }}
{%- if settings.env %}
  {%- for k,v in settings.env.items() %}
        {{ k }}={{ v }}
  {%- endfor %}
{%- endif %}

/etc/systemd/system/backup.service:
  file.managed:
    - source: salt://app/backup/app-backup.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: {{ settings.default_test_repository }}
      - file: /usr/local/lib/backup-service.sh
      - sls: backup.restic

/etc/systemd/system/initial-backup.service:
  file.managed:
    - source: salt://app/backup/app-backup.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: /etc/systemd/system/backup.service

/etc/systemd/system/backup.timer:
  file.managed:
    - source: salt://backup/backup.timer
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: /etc/systemd/system/backup.service

backup_systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/backup.service
      - file: /etc/systemd/system/backup.timer

{# if restic protocol = sftp: create ~/.ssh/config, paste ssh keys #}
{% if settings.repository_url.startswith('sftp:') %}
  {%- set url_regex= '(sftp):([^@]+)@([^:]+):([0-9]*)(.*)' %}
  {%- set backup_user= settings.repository_url|regex_replace(url_regex, '\\2') %}
  {%- set backup_host= settings.repository_url|regex_replace(url_regex, '\\3') %}
  {%- set backup_port= settings.repository_url|regex_replace(url_regex, '\\4') %}
  {%- if backup_port == '' %}
    {%- set backup_port=settings.default_ssh_port %}
  {%- endif %}

{{ settings.home_dir }}/.ssh/config:
  cmd.run:
    - name: install -o {{ settings.user }} -g {{ settings.user }} -m "0700" /dev/null {{ settings.home_dir }}/.ssh/config
    - unless: test -e {{ settings.home_dir }}/.ssh/config
  file.blockreplace:
    - marker_start: |
        ### BACKUP-CONFIG-BEGIN ###
    - marker_end: |
        ### BACKUP-CONFIG-END ###
    - append_if_not_found: true
    - content: |
        host {{ backup_host }}
  {%- if backup_port != settings.default_ssh_port %}
          Port {{ backup_port }}
  {%- endif %}
          IdentityFile ~/.ssh/id_ed25519_app_backup
          IdentitiesOnly yes
          ServerAliveInterval 60
          ServerAliveCountMax 240
    - require:
      - sls: app.home
      - cmd: {{ settings.home_dir }}/.ssh/config

{{ settings.home_dir }}/.ssh/id_ed25519_app_backup:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "600"
    - contents: |
{{ settings.ssh_id|indent(8,True) }}
    - require:
      - sls: app.home

{{ settings.home_dir }}/.ssh/id_ed25519_app_backup.pub:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "600"
    - contents: |
{{ settomgs.ssh_id_pub)|indent(8,True) }}
    - require:
      - sls: app.home

{% endif %}


{# if settings.repository_url points to default, setup the default backup repository #}
{% if settings.repository_url == settings.default_test_repository %}
create_default_test_repository:
  cmd.run:
    - name: restic init
    - unless: test -f {{ settings.repository_url }}/config
    - runas: {{ settings.user }}
    - cwd: {{ settings.home_dir }}
    - env:
      - HOME: {{ settings.home_dir }}
      - RESTIC_REPOSITORY: {{ settings.repository_url }}
      - RESTIC_PASSWORD: {{ settings.repository_key }}
  {%- if settings.env %}
    {%- for k,v in settings.env.items() %}
      - {{ k }}: {{ v }}
    {%- endfor %}
  {%- endif %}
    - require:
      - file: {{ settings.default_test_repository }}
      - sls: app.home
      - sls: app.backup.restic

create_default_backup_id_tag:
  cmd.run:
    - name: |
        echo $(restic cat config --json | \
          python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" 'id') \
          > {{ settings.etc_dir }}/tags/app_backup_id
    - runas: {{ settings.user }}
    - cwd: {{ settings.home_dir }}
    - env:
      - HOME: {{ settings.home_dir }}
      - RESTIC_REPOSITORY: {{ settings.repository_url }}
      - RESTIC_PASSWORD: {{ settings.repository_key }}
  {%- if settings.env %}
    {%- for k,v in settings.env.items() %}
      - {{ k }}: {{ v }}
    {%- endfor %}
  {%- endif %}
    - require:
      - sls: app.home
      - sls: app.scripts
    - onchanges:
      - cmd: create_default_test_repository
{% endif %}


app-backup.timer:
{%- if settings.enabled %}
  service.running:
    - enable: true
{%- else %}
  service.dead:
    - enable: false
{%- endif %}
    - require:
      - file: /etc/systemd/system/app-backup.timer
    - watch:
      - file: /etc/systemd/system/app-backup.timer
      - file: /etc/systemd/system/app-backup.service
