{% from "roles/imgbuilder/dokku/lib.sls" import create_container, dokku_files, dokku_post_commit with context %}

{% import_yaml "roles/imgbuilder/templates/dokku/"+ pillar['name']+ "/dokku.yml" as data with context %}

{% set files_touched=[] %}
{# dokku_files(pillar['name'], data, files_touched) #}

{{ create_container(pillar['name'], data) }}
