include:
  - desktop.android.sdk



get_wahtsapp_apk:
  cmd.run:
    - name: gplaycli -d whatsappid
    
start_android_emulator:
  cmd.run:
    - name: xxxx
    
install_whatsapp_apk:
  cmd.run:
    - name: adb install apk_file_of_whatsapp

{#
http://auroraoss.com:8080/
https://github.com/tulir/mautrix-whatsapp/wiki/Android-VM-Setup
#}


