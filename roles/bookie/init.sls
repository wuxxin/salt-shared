include:
  - git
  - postgresql.databases
  - postgresql.client
  - postgresql.dev
  - uwsgi
  - ngnix

make:
  pkg:
    - installed

sysdeps_via_salt:
  pkg.installed:
    - pkgs:
      - build-essential
      - git
      - libxslt1-dev
      - libxml2-dev
      - python-dev
      - libpq-dev
      - python-virtualenv
      - rrdtool
      - unzip
sysdeps_via_make:
  cmd.run:
    - cwd: /home/bookie/bookie
    - name: make sysdeps
    - require:
      - pkg: make
    - watch:
      - git: bookie

bookie:
  group:
    - present
  user:
    - present
    - gid: bookie
    - home: /home/bookie
    - shell: /bin/bash
    - require:
      - group: bookie
  git.latest:
    - name: https://github.com/mitechie/Bookie.git
    - target: /home/bookie/bookie
    - runas: bookie
    - submodules: True
    - require:
      - user: bookie
      - pkg: git
  virtualenv.managed:
    - name: /home/bookie/bookie
    - cwd: /home/bookie/bookie
    - runas: bookie
    - no_site_packages: True
    - require:
      - pkg: sysdeps_via_salt
    - watch:
      - git: bookie
  pip.installed:
    - cwd: /home/bookie/bookie
    - bin_env: /home/bookie/bookie
    - runas: bookie
    - no-index: True
    - no-deps: True
    - requirements: /home/bookie/bookie/requirements.txt
    - find-links: file:///home/bookie/bookie/download-cache/python
    - require:
      - virtualenv: bookie
    - watch:
      - git: bookie

css_js_setup:
  cmd.run:
    - cwd: /home/bookie/bookie
    - user: bookie
    - group: bookie
    - name: . ./bin/activate; make chrome_css js
    - require:
      - file: config_bookie_ini
      - pip: bookie
    - watch:
      - git: bookie

database_setup:
  cmd.run:
    - cwd: /home/bookie/bookie
    - user: bookie
    - group: bookie
    - name: . ./bin/activate; bin/alembic upgrade head
    - require:
      - file: config_bookie_ini
      - pip: bookie
      - cmd: postgresql_createdb bookie
    - watch:
      - git: bookie

create_bookie_ini:
  cmd.run:
    - cwd: /home/bookie/bookie
    - name: cp sample.ini bookie.ini
    - unless: test -f bookie.ini
    - require:
      - git: bookie
