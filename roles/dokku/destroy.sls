{% from "roles/dokku/lib.sls" import destroy_container with context %}

{% import_yaml "roles/dokku/templates/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ destroy_container(pillar['name'], data) }}
