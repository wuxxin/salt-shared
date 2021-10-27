{% macro redroid_image() %}
{%- from "android/redroid/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import image, container with context %}
{# download container image #}
{{ image(settings.redroid_image.image, settings.redroid_image.tag) }}
{# create customized image  #}
{{ container(settings.redroid_build) }}
{% endmacro %}

{% macro redroid_service(profile_definition, user='') %}
{%- from "android/redroid/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import container with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.redroid_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}
