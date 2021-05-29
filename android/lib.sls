
{% macro image_build(image_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.image_build},
  grain='default', default= 'default', merge=image_definition) %}
{{ container(entry) }}
{% endmacro %}

{% macro emulator_desktop(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_desktop},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry) }}
{% endmacro %}

{% macro emulator_headless_service(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_headless_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry) }}
{% endmacro %}

{% macro emulator_webrtc_service(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_webrtc_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry) }}
{% endmacro %}

{% macro redroid_service(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.redroid_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry) }}
{% endmacro %}
