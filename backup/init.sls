{% from "backup/defaults.jinja" import settings with context %}

{% set default_test_repository= '/opt/app-backup-test' %}
{% set backup_url= salt['pillar.get']('backup:repository:url') %}
{% set backup_list= [settings.etc_dir, settings.pgdump_dir, settings.media_dir,
                        settings.upload_dir, settings.maildir_dir] %}
{% set backup_excludes= '--exclude '+ settings.media_dir+ '/lost+found '+
  ' '+ '--exclude '+ settings.media_dir+ '/temp' %}
{# set restic cache= settings.home_dir+ '/.cache/restic' #}

include:
  - app.home
  - app.scripts
  - app.systemd.reload
  - app.backup.restic

{# always create default backup path, so backup completes in default config #}
{{ default_test_repository }}:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - dir_mode: "700"

/usr/local/sbin/app-restic.sh:
  file.managed:
    - source: salt://app/backup/app-restic.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - mode: "0755"

/usr/local/sbin/app-recover-from-backup.sh:
  file.managed:
    - source: salt://app/backup/app-recover-from-backup.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
        locale_lang: {{ locale_settings.lang }}
        database: {{ salt['pillar.get']('app:database') }}
        backup_list: {{ backup_list }}
    - mode: "0755"

/usr/local/bin/app-backup.sh:
  file.managed:
    - source: salt://app/backup/app-backup.sh
    - template: jinja
    - defaults:
        settings: {{ settings }}
        backup_list: {{ backup_list }}
        backup_excludes: {{ backup_excludes }}
    - mode: "0755"
    - require:
      - sls: app.scripts

/etc/systemd/system/app-backup.service:
  file.managed:
    - source: salt://app/backup/app-backup.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
        size: {{ salt['pillar.get']('backup:repository:size', 0) }}
        {%- if salt['pillar.get']('backup:env', false) %}
        env:
          {%- for k,v in salt['pillar.get']('backup:env').items() %}
          {{ k }}: {{ v }}
          {%- endfor %}
        {%- else %}
        env: false
        {%- endif %}
    - require:
      - file: {{ default_test_repository }}
      - file: /usr/local/bin/app-backup.sh
      - sls: app.backup.restic
    - onchanges_in:
      - cmd: systemd_reload

/etc/systemd/system/app-backup.timer:
  file.managed:
    - source: salt://app/backup/app-backup.timer
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - file: /etc/systemd/system/app-backup.service


{# if restic protocol = sftp: create ~/.ssh/config, paste ssh keys #}
{% if backup_url.startswith('sftp:') %}
  {%- set url_regex= '(sftp):([^@]+)@([^:]+):(.+)' %}
  {%- set backup_user= backup_url|regex_replace(url_regex, '\\2') %}
  {%- set backup_host= backup_url|regex_replace(url_regex, '\\3') %}

{{ settings.home_dir }}/.ssh/config:
  cmd.run:
    - name: install -o {{ settings.user }} -g {{ settings.user }} -m "0700" /dev/null {{ settings.home_dir }}/.ssh/config
    - unless: test -e {{ settings.home_dir }}/.ssh/config
  file.blockreplace:
    - marker_start: |
        ### APP-BACKUP-CONFIG-BEGIN ###
    - marker_end: |
        ### APP-BACKUP-CONFIG-END ###
    - append_if_not_found: true
    - content: |
        host {{ backup_host }}
  {%- if salt['pillar.get']('backup:repository:ssh_port', false) %}
          Port {{ salt['pillar.get']('backup:repository:ssh_port') }}
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
{{ salt['pillar.get']('backup:repository:ssh_id')|indent(8,True) }}
    - require:
      - sls: app.home

{{ settings.home_dir }}/.ssh/id_ed25519_app_backup.pub:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "600"
    - contents: |
{{ salt['pillar.get']('backup:repository:ssh_id_pub')|indent(8,True) }}
    - require:
      - sls: app.home

{% endif %}


{# if backup_url points to default, setup the default backup repository #}
{% if backup_url == default_test_repository %}
create_default_test_repository:
  cmd.run:
    - name: restic init
    - unless: test -f {{ backup_url }}/config
    - runas: {{ settings.user }}
    - cwd: {{ settings.home_dir }}
    - env:
      - HOME: {{ settings.home_dir }}
      - RESTIC_REPOSITORY: {{ backup_url }}
      - RESTIC_PASSWORD: {{ salt['pillar.get']('backup:key') }}
  {%- if salt['pillar.get']('backup:env', false) %}
    {%- for k,v in salt['pillar.get']('backup:env').items() %}
      - {{ k }}: {{ v }}
    {%- endfor %}
  {%- endif %}
    - require:
      - file: {{ default_test_repository }}
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
      - RESTIC_REPOSITORY: {{ backup_url }}
      - RESTIC_PASSWORD: {{ salt['pillar.get']('backup:key') }}
  {%- if salt['pillar.get']('backup:env', false) %}
    {%- for k,v in salt['pillar.get']('backup:env').items() %}
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
{%- if salt['pillar.get']('backup:enabled', true) %}
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
