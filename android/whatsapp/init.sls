{% from "android.emulator-container.sls" import android_emulator_desktop %}
{% from "containers/defaults.jinja" import settings as container_settings with context %}

include:
  - android.emulator-container

{% load_yaml as whatsapp_emulator_definition %}
name: whatsapp-container
environment:
  ANDROID_DATA_VOLUME: android-whatsapp
  ADD_EMULATOR_PARAMS: "-netdelay umts -netspeed hsdpa -camera-front webcam1"
desktop:
  template: host
  options:
    - "--webcam"
{% endload %}

{{ android_emulator_desktop(whatsapp_emulator_definition, user) }}

{#
download-whatsapp.apk:
  cmd.run:
    - name: gplaycli -d whatsappid
    - require:
      - sls: android

install-whatsapp.apk:
  cmd.run:
    - name: adb install apk_file_of_whatsapp
    - require:
      - cmd: download-whatsapp.apk
      - cmd: whatsapp-container


https://github.com/tulir/mautrix-whatsapp/wiki/Android-VM-Setup
#}
