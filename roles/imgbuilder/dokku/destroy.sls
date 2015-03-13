{% from "roles/imgbuilder/dokku/lib.sls" import destroy_container with context %}

{% import_yaml "roles/imgbuilder/templates/dokku/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ destroy_container(pillar['name'], data) }}
