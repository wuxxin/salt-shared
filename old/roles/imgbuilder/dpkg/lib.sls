
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% set base= s.image_base+ "/templates/git-buildpackage" %}

{% macro buildpackage(name, source) %}

clone_{{ name }}:
  git.latest:
    - name: {{ source }}
    - target: {{ base }}/{{ name }}
    - user: {{ s.user }}
    - group: {{ s.user }}

build_{{ name }}:
  cmd.run:
    - cwd: {{ base }}/{{ name }}
    - name: gbp buildpackage --git-pbuilder
    - runas: {{ s.user }}
    
{% endmacro %}
