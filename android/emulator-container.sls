{% from "android/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose, desktop_application %}

include:
  - python
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
{{ desktop_application(profile_definition) }}
{% endmacro %}

{% macro android_emulator_headless_service(profile_definition) %}
{% endmacro %}

{% macro android_emulator_webrtc_service(profile_definition) %}
{% endmacro %}
