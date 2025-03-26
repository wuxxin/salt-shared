{% macro emulator_image() %}
{%- from "android/emulator/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import image, container with context %}
{# download emulator container image #}
{{ image(settings.emulator.image, settings.emulator.tag) }}
{# create customized emulator container to also work with gui #}
{{ container(settings.emulator_build) }}
{% endmacro %}


{% macro emulator_desktop(profile_definition) %}
{%- from "android/emulator/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import container with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_desktop},
  grain='default', default= 'default', merge=profile_definition) %}
{%- if entry.desktop.entry.Exec is not defined %}
  {%- do entry.desktop.entry.update({'Exec': 'sudo ' ~ entry.name ~ '.sh'}) %}
{%- endif %}
{{ container(entry) }}
{% endmacro %}


{% macro emulator_headless_service(profile_definition) %}
{%- from "android/emulator/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import container with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_headless_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry) }}
{% endmacro %}


{% macro emulator_webrtc_service(profile_definition) %}
{%- from "android/emulator/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import compose with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_webrtc_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry) }}
{% endmacro %}
