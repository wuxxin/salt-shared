include:
  - .ppa

gitlab-prereq:
  pkg:
    - installed
    - pkgs:
      - vim 
      - curl
      - wget
      - sudo
      - net-tools
      - pwgen 
      - unzip
      - logrotate
      - nginx
      - redis-server
      - postgresql-client
      - python2.7
      - python-docutils

gitlab-prereq-gems:
  pkg.installed:
    - pkgs:
      - libqtwebkit-dev
      - libsqlite3-dev
      - libmysqlclient-dev
      - libpq-dev
      - zlib1g-dev
      - libyaml-dev
      - libssl-dev
      - libxml2-dev
      - libxslt-dev
      - libcurl4-openssl-dev
      - libicu-dev
      - libgdbm-dev
      - libreadline-dev
      - libncurses5-dev
      - libffi-dev
    - require:
      - pkg: gitlab-prereq

gitlab-prereq-git:
  pkg.latest:
    - name: git-core
    - require:
      - pkgrepo: git-core-ppa

gitlab-all-prereq:
  cmd.run:
    - name: echo 'OK, gitlab-all-rereq'
    - require:
      - pkg: gitlab-prereq-gems
      - pkg: gitlab-prereq-git

{% from "roles/gitlab/defaults.jinja" import template with context %}
{% set gitlab_config=salt['grains.filter_by']({'default': template}, grain='none', merge= pillar.gitlab|d({})) %}

{% if gitlab_config.DB_HOST == "localhost" %}
  {% if gitlab_config.DB_TYPE == "mysql" %}
      - pkg: gitlab-mysql-server

gitlab-mysql-server:
    pkg.installed:
      - name: mysql-server
  {% elif gitlab_config.DB_TYPE == "postgresql" %}
      - pkg: gitlab-postgresql-server

gitlab-postgresql-server:
    pkg.installed:
      - name: postgresql

  {% endif %}
{% endif %}
