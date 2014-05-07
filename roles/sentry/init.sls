include:
  - nginx
  - uwsgi

  - virtualenv
  - pip

  - postgresql
  - statsd
  - diamond

sentry:
  pkg.installed:
    pkgs:
      - postgresql 
      - postgresql-contrib
      - libpq-dev
      - psycopg2
      - build-essential
      - python-dev
      - python-virtualenv
      - python-pip
      - libevent-dev
  group:
    - present
  user.present:
    - group: sentry
    - require:
      - group: sentry
  virtualenv.manage:
    - name: /home/sentry/environment
    - no_site_packages: True
    - require:
      - pkg: sentry
      - user: sentry
  pip.installed:
    - name: sentry[postgres]
    - bin_env: /home/sentry/environment/bin/pip
    - require:
      - virtualenv: sentry
  postgres_user:
    - present
    - name: {{ pillar['sentry']['db']['username'] }}
    - password: {{ pillar['sentry']['db']['password'] }}
    - require:
      - service: postgresql-server
  postgres_database:
    - present
    - name: {{ pillar['sentry']['db']['name'] }}
    - owner: {{ pillar['sentry']['db']['username'] }}
    - encoding: utf-8
    - require:
      - postgres_user: sentry
      - service: postgresql-server

sentry_settings:
  file:
    - managed
    - name: /home/sentry/.sentry/sentry.conf.py
    - makedirs: true
    - template: jinja
    - user: sentry
    - group: sentry
    - mode: 440
    - source: salt://roles/sentry/config.jinja2
    - context: {{ pillar['sentry'] }}
  cmd:
    - wait
    - stateful: False
    - user: sentry
    - group: sentry
    - name:  /home/sentry/environment/bin/sentry --config=/home/sentry/.sentry/sentry.conf.py upgrade --noinput
    - require:
      - pip: sentry
      - postgres_database: sentry
    - watch:
      - module: sentry
      - file: sentry_settings

sentry-syncdb-all:
  cmd:
    - wait
    - name: /home/sentry/environment/bin/sentry --config=/home/sentry/.sentry/sentry.conf.py syncdb --all --noinput
    - stateful: False
    - require:
      - pip: sentry
      - file: sentry_settings
    - watch:
      - postgres_database: sentry

sentry-migrate-fake:
  cmd:
    - wait
    - name: /home/sentry/environment/bin/sentry --config=/home/sentry/.sentry/sentry.conf.py migrate --fake --noinput
    - stateful: False
    - watch:
      - cmd: sentry-syncdb-all


/etc/uwsgi/sentry.ini:
  file:
    - managed
    - template: jinja
    - user: www-data
    - group: www-data
    - mode: 440
    - source: salt://roles/sentry/uwsgi.jinja2
    - context: {{ pillar['sentry'] }}
    - require:
      - service: uwsgi_emperor
      - cmd: sentry_settings
  module:
    - wait
    - name: file.touch
    - m_name: /etc/uwsgi/sentry.ini
    - require:
      - file: /etc/uwsgi/sentry.ini
    - watch:
      - file: sentry
      - cmd: sentry_settings


{% if 'backup_server' in pillar %}
/etc/cron.daily/backup-sentry:
  file:
    - managed
    - user: root
    - group: root
    - mode: 500
    - template: jinja
    - source: salt://roles/sentry/backup.jinja2
{% endif %}

uwsgi_diamond_sentry:
  file:
    - accumulated
    - name: processes
    - filename: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - require_in:
      - file: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - text:
      - |
        [[uwsgi.sentry]]
        cmdline = ^sentry-(worker|master)$

/etc/nginx/conf.d/sentry.conf:
  file:
    - managed
    - template: jinja
    - user: www-data
    - group: www-data
    - mode: 440
    - source: salt://roles/sentry/nginx.jinja2
    - context: {{ pillar['sentry'] }}

extend:
  nginx:
    service:
      - watch:
        - file: /etc/nginx/conf.d/sentry.conf
