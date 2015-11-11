{% from "roles/dokku/lib.sls" import create_container, dokku_files, dokku_post_commit with context %}

{% import_yaml "roles/dokku/templates/"+ pillar['name']+ "/dokku.yml" as data with context %}

{% set files_touched=[] %}
{{ dokku_post_commit(pillar['name'], data) }}
