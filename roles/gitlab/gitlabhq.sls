include:
  - .directories
  - .prereq
  - .ruby
  - .gitlab-shell

{% from "roles/gitlab/defaults.jinja" import template with context %}
{% set gitlab_config=salt['grains.filter_by']({'default': template}, grain='none', merge= pillar.gitlab|d({})) %}

gitlabhq-{{ gitlab_config.GITLAB_VERSION }}:
  archive.extracted:
    - name: /home/git/
    - source: https://github.com/gitlabhq/gitlabhq/archive/v{{ gitlab_config.GITLAB_VERSION }}.tar.gz
    - archive_format: tar
    - source_hash: md5={{ gitlab_config.GITLAB_TGZ_MD5 }}
    - tar_options: z
    - if_missing: /home/git/gitlabhq-{{ gitlab_config.GITLAB_VERSION }}
    - require:
      - file: gitlab-directories
  file.directory:
    - name: /home/git/gitlabhq-{{ gitlab_config.GITLAB_VERSION }}
    - user: git
    - group: git
    - recurse:
        - user
        - group
    - require:
      - archive: gitlabhq-{{ gitlab_config.GITLAB_VERSION }}

gitlabhq-symlink:
  file.symlink:
    - name: /home/git/gitlab
    - target: /home/git/gitlabhq-{{ gitlab_config.GITLAB_VERSION }}
    - require:
      - file: gitlabhq-{{ gitlab_config.GITLAB_VERSION }}

{% for a in ('log', 'tmp', 'tmp/pids', 'tmp/sockets') %}
gitlabhq-dir-{{ a }}:
  file.directory:
    - name: /home/git/gitlab/{{ a }}
    - user: git
    - group: git
    - recurse:
      - user
      - group
    - require:
      - file: gitlabhq-symlink
    - require_in:
      - cmd: gitlabhq-config
{% endfor %}

gitlabhq-chmod:
  cmd.run:
    - name: chmod -R u+rwX /home/git/gitlab/log /home/git/gitlab/tmp
    - require:
      - file: gitlabhq-dir-log
      - file: gitlabhq-dir-tmp
    - require_in:
      - cmd: gitlabhq-config

/home/git/gitlab/public/uploads:
  file.symlink:
    - target: /home/git/data/uploads
    - require:
      - file: gitlab-directories
    - require_in:
      - cmd: gitlabhq-config

/home/git/gitlab/tmp/backups:
  file.symlink:
    - target: /home/git/data/backups
    - require:
      - file: gitlab-directories
      - file: gitlabhq-dir-tmp
    - require_in:
      - cmd: gitlabhq-config

gitlabhq-config:
  file.recurse:
    - name: /home/git/gitlab/config
    - source: salt://roles/gitlab/data/gitlabhq
    - user: git
    - group: git
    - template: jinja
    - context: {{ gitlab_config }}
    - require:
      - file: gitlabhq-symlink
  cmd.run:
    - name: cd /home/git/gitlab; bundle install --deployment --without development test aws
    - user: git
    - group: git
    - require:
      - file: gitlabhq-config
      - cmd: gitlab-default-ruby
      - cmd: gitlab-all-prereq
      - cmd: gitlab-shell-config

gitlabhq-logrotate:
  file.copy:
    - source: /home/git/gitlab/lib/support/logrotate/gitlab
    - name: /etc/logrotate.d/gitlab
    - force: true
    - require:
      - cmd: gitlabhq-config

gitlabhq-init:
  file.copy:
    - source: /home/git/gitlab/lib/support/init.d/gitlab
    - name: /etc/init.d/gitlab
    - force: true
    - require:
      - cmd: gitlabhq-config

/etc/init.d/gitlab:
  file.managed:
    - mode: 755
    - require:
      - file: gitlabhq-init

gitlabhq-done:
  cmd.run:
    - name: echo "OK-gitlabhq-done"
    - require:
      - file: /etc/init.d/gitlab
