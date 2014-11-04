include:
  - rbenv

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{% from "rbenv/lib.sls" import default_local_ruby with context %}
{{ default_local_ruby(s.user,'') }}
