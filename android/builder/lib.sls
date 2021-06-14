
{% macro build_image(image_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.image_build},
  grain='default', default= 'default', merge=image_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}
