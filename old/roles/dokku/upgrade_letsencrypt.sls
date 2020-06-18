{% from "old/roles/dokku/lib.sls" import dokku_certs with context %}
{% from "old/roles/dokku/defaults.jinja" import settings as s with context %}
{% import_yaml s.templates.source+ "/"+ pillar['name']+ "/dokku.yml" as data with context %}

{{ dokku_certs(pillar['name'], data) }}
