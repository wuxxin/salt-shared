
{% macro emulator_image(profile_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_build},
  grain='default', default= 'default', merge=profile_definition) %}
{%- set gosu_user = '' if user == '' else 'gosu ' ~ user ~ ' ' %}
{%- set postfix_user = '' if user == '' else '_' ~ user %}

{# download emulator container image #}
{{ image(settings.emulator.image, settings.emulator.tag, user=user) }}

{# tag emulator container #}
tag_latest_android_emulator{{ postfix_user }}:
  cmd.run:
    - name: {{ gosu_user }} podman image tag {{ settings.emulator.image }}:{{ settings.emulator.tag }} \
        localhost/android-emulator-unmodified:latest
    - onchanges:
      - cmd: containers_image_{{ settings.emulator.image }}{{ postfix_user }}

{# create modified emulator (to also work with gui) #}
{{ container(entry, user=user) }}
{% endmacro %}


{% macro emulator_desktop(profile_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_desktop},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}


{% macro emulator_headless_service(profile_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_headless_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry, user=user) }}
{% endmacro %}


{% macro emulator_webrtc_service(profile_definition, user='') %}
{%- from "android/defaults.jinja" import settings with context %}
{%- from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}
{%- set entry= salt['grains.filter_by']({'default': settings.emulator_webrtc_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry, user=user) }}
{% endmacro %}
