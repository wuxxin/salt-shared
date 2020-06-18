{% from "old/roles/dokku/lib.sls" import dokku_env with context %}
{% from "old/roles/dokku/defaults.jinja" import settings as s with context %}
{% import_yaml s.templates.source+ "/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ dokku_env(pillar['name'], data) }}
