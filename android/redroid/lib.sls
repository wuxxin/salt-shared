
{% macro redroid_service(profile_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.redroid_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry, user=user) }}
{% endmacro %}
