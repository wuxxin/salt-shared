{% macro dockdroid(profile_definition, user='') %}
{%- from "android/dockdroid/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import container with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.container},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}
