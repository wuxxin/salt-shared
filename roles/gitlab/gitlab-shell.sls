include:
  - .directories
  - .prereq
  - .ruby

{% from "roles/gitlab/defaults.jinja" import template with context %}
{% set gitlab_config=salt['grains.filter_by']({'default': template}, grain='none', merge= pillar.gitlab|d({})) %}

gitlab-shell-{{ gitlab_config.SHELL_VERSION }}:
  archive.extracted:
    - name: /home/git/
    - source: https://github.com/gitlabhq/gitlab-shell/archive/v{{ gitlab_config.SHELL_VERSION }}.tar.gz
    - source_hash: md5={{ gitlab_config.SHELL_TGZ_MD5 }}
    - archive_format: tar
    - tar_options: z
    - if_missing: /home/git/gitlab-shell-{{ gitlab_config.SHELL_VERSION }}
    - require:
      - file: gitlab-directories
  file.directory:
    - name: /home/git/gitlab-shell-{{ gitlab_config.SHELL_VERSION }}
    - user: git
    - group: git
    - recurse:
        - user
        - group
    - require: 
      - archive: gitlab-shell-{{ gitlab_config.SHELL_VERSION }}

gitlab-shell:
  file.symlink:
    - name: /home/git/gitlab-shell
    - target: /home/git/gitlab-shell-{{ gitlab_config.SHELL_VERSION }}
    - require:
      - file: gitlab-shell-{{ gitlab_config.SHELL_VERSION }}

gitlab-shell-config:
  file.managed:
    - name: /home/git/gitlab-shell/config.yml
    - source: salt://roles/gitlab/data/gitlab-shell/config.yml
    - user: git
    - group: git
    - template: jinja
    - context: {{ gitlab_config }}
    - require:
      - file: gitlab-shell
  cmd.run:
    - name: cd /home/git/gitlab-shell; ./bin/install
    - user: git
    - group: git
    - require:
      - file: gitlab-shell-config
      - cmd: gitlab-default-ruby
      - cmd: gitlab-all-prereq


