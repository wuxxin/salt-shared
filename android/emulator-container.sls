{% from "android/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import volume, image, container, compose %}

include:
  - android.tools
  - containers
  - containers.gui

{# download emulator container image #}
{{ image(settings.emulator.image, settings.emulator.tag) }}

{# tag emulator container #}
set_latest_android_emulator_unmodified:
  cmd.run:
    - name: podman image tag {{ settings.emulator.image }}:{{ settings.emulator.tag }} \
        localhost/android-emulator-unmodified:latest
    - onchanges:
      - cmd: containers_image_{{ settings.emulator.image }}

{# create modified emulator (to also work with gui) #}
{{ container(settings.container.emulator_build) }}

{# for launch parameter of emulator see
  https://developer.android.com/studio/run/emulator-commandline
#}

{% macro android_emulator_desktop(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_desktop},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry) }}
{% endmacro %}

{% macro android_emulator_headless_service(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_headless_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ container(entry) }}
{% endmacro %}

{% macro android_emulator_webrtc_service(profile_definition) %}
{%- from "android/defaults.jinja" import settings with context %}
{%- set entry= salt['grains.filter_by']({'default': settings.container.emulator_webrtc_service},
  grain='default', default= 'default', merge=profile_definition) %}
{{ compose(entry) }}
{% endmacro %}
