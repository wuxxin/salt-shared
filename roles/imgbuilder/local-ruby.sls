include:
  - rbenv

{% from "rbenv/lib.sls" import default_local_ruby with context %}
{{ default_local_ruby('imgbuilder','') }}
