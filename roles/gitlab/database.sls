include:
  - .prereq

{% from "roles/gitlab/defaults.jinja" import template with context %}
{% set gitlab_config=salt['grains.filter_by']({'default': template}, grain='none', merge= pillar.gitlab|d({})) %}

{% if gitlab_config.DB_HOST == "localhost" %}
{% if gitlab_config.DB_TYPE == "mysql" %}

gitlabhq-database:
  mysql_user.present:
    - name: {{ gitlab_config.DB_USER }}
    - password: {{ gitlab_config.DB_PASS }}
    - connection_charset: {{ gitlab_config.DB_ENCODING }}
    - require:
      - cmd: gitlab-all-prereq
  mysql_database.present:
    - name: {{ gitlab_config.DB_NAME }}
    - require:
      - cmd: gitlab-all-prereq
  mysql_grants.present:
    - grant: all
    - database: {{ gitlab_config.DB_NAME }}
    - user: {{ gitlab_config.DB_USER }}
    - require:
      - mysql_user: gitlabhq-database
      - mysql_database: gitlabhq-database
  cmd.run:
    - name: "echo 'OK, gitlabhq-database'"
    - require:
      - mysql_grants: gitlabhq-database
  
{% elif gitlab_config.DB_TYPE == "postgresql" %}

gitlabhq-database:
  postgres_user.present:
    - name: {{ gitlab_config.DB_USER }}
    - password: {{ gitlab_config.DB_PASS }}
    - require:
      - cmd: gitlab-all-prereq
  postgres_database.present:
    - name: {{ gitlab_config.DB_NAME }}
    - owner: {{ gitlab_config.DB_USER }}
    - require:
      - postgres_user: gitlabhq-database
  cmd.run:
    - name: "echo 'OK, gitlabhq-database'"
    - require:
      - postgres_database: gitlabhq-database


{% endif %}
{% endif %}

