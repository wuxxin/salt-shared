{% from "roles/dokku/lib.sls" import create_container with context %}
{% from "roles/dokku/defaults.jinja" import settings as s with context %}
{% import_yaml s.templates.source+ "/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ create_container(pillar['name'], data, only_prepare=True) }}
