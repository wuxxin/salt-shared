include:
  - desktop.android.user.configure

create_whatsapp_avd:
  cmd.run:
    - name: avdmanager create avd -n whatsapp -k android-28

start_whatsapp_avd:
  cmd.run:
    - name: emulator -avd whatsapp -no-audio -no-window -show-kernel -memory 2048

# - name: 'emulator -gpu on -memory 1024 @test'
