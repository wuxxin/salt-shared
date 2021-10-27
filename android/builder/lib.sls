
{% macro build_image(image_definition, user='') %}
{%- from "android/builder/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import container with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.image_build},
  grain='default', default= 'default', merge=image_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}
