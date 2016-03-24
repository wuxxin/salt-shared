{% from "roles/dokku/lib.sls" import dokku_git_push, dokku_post_commit with context %}
{% from "roles/dokku/defaults.jinja" import settings as s with context %}
{% import_yaml s.templates.source+ "/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ dokku_git_push(pillar['name'], data) }}
{{ dokku_post_commit(pillar['name'], data) }}
