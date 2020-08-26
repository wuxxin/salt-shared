include:
  - android
  - containers
  - android.emulator-container

{% from "containers/lib.sls" import volume, container, compose %}

{{ volume(name) }}
{{ container(pod) }}

download_whatsapp_apk:
  cmd.run:
    - name: gplaycli -d whatsappid
    - require:
      - sls: android

install_whatsapp_apk:
  cmd.run:
    - name: adb install apk_file_of_whatsapp
    - require:
      - cmd: download_whatsapp_apk
      - cmd: start_whatsapp_android_emulator

{#
name: emulator -avd whatsapp -no-audio -no-window -show-kernel -memory 2048
name: emulator -gpu on -memory 1024 @test
https://github.com/tulir/mautrix-whatsapp/wiki/Android-VM-Setup
#}
