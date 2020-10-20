{% from "android.emulator-container.sls" import android_emulator_desktop %}
{% from "android.defaults.jinja" import settings with context %}

include:
  - android.emulator-container

{% load_yaml as whatsapp_emulator_definition %}
name: whatsapp-container
environment:
  ANDROID_DATA_VOLUME: android-whatsapp
  ADD_EMULATOR_PARAMS: "-netdelay umts -netspeed hsdpa -camera-front webcam1"
x11docker: {{ settings.default_args.x11docker + ['--webcam'] }}
{% endload %}

{{ android_emulator_desktop(user, whatsapp_emulator_definition) }}


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
