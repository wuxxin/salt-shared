# Android

## Create and launch android emulator as container

+ android_emulator_desktop()
+ android_emulator_headless_service()
+ android_emulator_webrtc_service()

## Configure

environment:
  ANDROID_DATA_VOLUME: name-of-instance-data-volume
  AVD_CONFIG: will be used instead of default_args:avd if not empty
  EMULATOR_PARAMS: will be used instead of default_args:emulator if not empty
  ADD_EMULATOR_PARAMS: additional emulator args
desktop:
  options:
    k:v of x11docker options
