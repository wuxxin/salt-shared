{% from "android/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, container, compose %}

include:
  - python
  - android.tools
  - containers
  - containers.gui

{# download emulator container image #}
{{ image(settings.emulator.image, settings.emulator.tag) }}

set_latest_android_emulator_unmodified:
  cmd.run:
    - name: podman image tag {{ settings.emulator.image }}:{{ settings.emulator.tag }} \
        localhost/android-emulator-unmodified:latest
    - onchanges:
      - cmd: containers_image_{{ settings.emulator.image }}

{% load_yaml as android_emulator_container %}
name: android-emulator
image: localhost/android-emulator
tag: latest
type: build
build:
  source: .
files:
  build/Dockerfile:
    contents: |
      FROM localhost/android-emulator-unmodified:latest

      # start signal
      CMD signal-desktop
  build/launch-emulator.sh:
    source: salt://android/launch-emulator.sh
{% endload %}

{# create modified emulator (to also work with gui) #}
{{ container(android_emulator_container) }}
