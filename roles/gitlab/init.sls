include:
  #- ssh.server
  - .user
  - .directories
  - .prereq
  - .ruby
  - .gitlab-shell
  - .gitlabhq
  - .database

pwgen:
  pkg:
    - installed
    - order: 2

{% from "roles/gitlab/defaults.jinja" import template with context %}
{% set gitlab_config=salt['grains.filter_by']({'default': template}, grain='none', merge= pillar.gitlab|d({})) %}

{% set rakes = [("assets","clean"), ("assets", "precompile"), ("cache", "clear"), ("gitlab", "check")] %}


{% if gitlab_config.DB_INIT == "yes" %}
gitlabhq-rake-gitlab-setup:
  cmd.run:
    - name: "cd /home/git/gitlab; force=yes bundle exec rake gitlab:setup RAILS_ENV=production"
    - user: git
    - group: git
    - require: 
      - cmd: gitlabhq-done
      - cmd: gitlabhq-database
{% endif %}

{% for (a,b) in rakes %}
gitlabhq-rake-{{ a }}-{{ b }}:
  cmd.run:
    - name: "cd /home/git/gitlab; bundle exec rake {{ a }}:{{ b }} RAILS_ENV=production"
    - user: git
    - group: git
    - require: 
      - cmd: gitlabhq-done
      - cmd: gitlabhq-database
{% endfor %}

gitlabhq:
  service.running:
    - enable: True
    - name: gitlab
    - watch: 
      - file: /etc/init.d/gitlab
    - require:
      - cmd: gitlabhq-done
{% if gitlab_config.DB_INIT == "yes" %}
      - cmd: gitlabhq-rake-gitlab-setup
{% endif %}
{% for (a,b) in rakes %}
      - cmd: gitlabhq-rake-{{ a }}-{{ b }}
{% endfor %}


/etc/nginx/sites-available/gitlab:
  file.managed:
    - source: salt://roles/gitlab/data/nginx/gitlab
    - template: jinja
    - context: {{ gitlab_config }}
    - require:
      - cmd: gitlabhq-done

/etc/nginx/sites-enabled/default:
  file.absent:
    - require:
      - file: /etc/nginx/sites-available/gitlab

/etc/nginx/sites-enabled/gitlab:
  file.symlink:
    - target: /etc/nginx/sites-available/gitlab
    - require:
      - file: /etc/nginx/sites-available/gitlab

nginx:
  service.running:
    - enable: True
    - name: nginx
    - watch: 
      - file: /etc/nginx/sites-enabled/gitlab
      - file: /etc/nginx/sites-enabled/default

kickstart_rails:
  cmd.run:
    - name: wget "http://localhost" -O /dev/null
    - require:
      - service: nginx
