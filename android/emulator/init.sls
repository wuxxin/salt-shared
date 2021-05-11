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
