{% from "roles/dokku/lib.sls" import dokku_files, dokku_pre_commit, dokku_git_commit, dokku_git_add_remote with context %}
{% from "roles/dokku/defaults.jinja" import settings as s with context %}
{% import_yaml s.templates.source+ "/"+ pillar['name']+ "/dokku.yml" as data with context %}

{% set files_touched=[] %}
{{ dokku_files(pillar['name'], data, files_touched) }}
{{ dokku_pre_commit(pillar['name'], data) }}
{{ dokku_git_commit(pillar['name'], data, files_touched) }}
{{ dokku_git_add_remote(pillar['name']) }}
