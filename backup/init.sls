{% from "backup/defaults.jinja" import settings with context %}

{% set default_test_repository= '/opt/backup-test' %}

{# exclude some files/dirs inside this directories#}

{# keep all snapshots from now to backup_keep_within back, forget and prune older snapshots #}
{% set backup_keep_within= '1y6m' %}

{# restic cache= settings.home_dir+ '/.cache/restic' #}

include:
  - backup.restic

{# always create default backup path, so backup completes in default config #}
{{ default_test_repository }}:
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
    - require:
      - sls: app.scripts

/etc/systemd/system/backup.service:
  file.managed:
    - source: salt://app/backup/app-backup.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: {{ default_test_repository }}
      - file: /usr/local/lib/backup-service.sh
      - sls: backup.restic
    - onchanges_in:
      - cmd: systemd_reload

/etc/systemd/system/backup.timer:
  file.managed:
    - source: salt://backup/backup.timer
    - onchanges_in:
      - cmd: systemd_reload
    - require:
      - file: /etc/systemd/system/backup.service


{# if restic protocol = sftp: create ~/.ssh/config, paste ssh keys #}
{% if settings.repository_url.startswith('sftp:') %}
  {%- set url_regex= '(sftp):([^@]+)@([^:]+):(.+)' %}
  {%- set backup_user= settings.repository_url|regex_replace(url_regex, '\\2') %}
  {%- set backup_host= settings.repository_url|regex_replace(url_regex, '\\3') %}

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
  {%- if salt['pillar.get']('app:backup:repository:ssh_port', false) %}
          Port {{ salt['pillar.get']('app:backup:repository:ssh_port') }}
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
{% if settings.repository_url == default_test_repository %}
create_default_test_repository:
  cmd.run:
    - name: restic init
    - unless: test -f {{ settings.repository_url }}/config
    - runas: {{ settings.user }}
    - cwd: {{ settings.home_dir }}
    - env:
      - HOME: {{ settings.home_dir }}
      - RESTIC_REPOSITORY: {{ settings.settings.repository_url }}
      - RESTIC_PASSWORD: {{ salt['pillar.get']('app:backup:key') }}
  {%- if settings.env %}
    {%- for k,v in settings.env.items() %}
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
      - RESTIC_REPOSITORY: {{ settings.repository_url }}
      - RESTIC_PASSWORD: {{ salt['pillar.get']('app:backup:key') }}
  {%- if settings.env %}
    {%- for k,v in salt['pillar.get']('app:backup:env').items() %}
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
{%- if salt['pillar.get']('app:backup:enabled', true) %}
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
