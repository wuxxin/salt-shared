include:
  - rbenv

{% from "rbenv/lib.sls" import default_local_ruby with context %}
{{ default_local_ruby(s.user,'2.2.0') }}
