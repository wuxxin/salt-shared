# Android

## android.tools

+ adb: Android Debug Bridge
+ fastboot: flashing an Android device, boot an Android device to fastboot mode
+ aapt: Android Asset Packaging Tool

## android.lib

### Build an android lineage version

+ android_image_build()

### Create and launch android emulator as container

+ android_emulator_desktop()
+ android_emulator_headless_service()
+ android_emulator_webrtc_service()

#### Configure

environment:
  ANDROID_DATA_VOLUME: name-of-instance-data-volume
  AVD_CONFIG: be used instead of default_args:avd if not empty
  EMULATOR_PARAMS: be used instead of default_args:emulator if not empty
  ADD_EMULATOR_PARAMS: additional emulator args
desktop:
  options:
    k:v of x11docker options

## Other Tools

+ https://github.com/remote-android/redroid-doc
  + ReDroid (Remote Android) is a GPU accelerated AIC (Android In Container) solution. You can boot many instances in Linux host or any Linux container envrionments (Docker, K8S, LXC etc.). ReDroid supports both arm64 and amd64 architectures. You can connect to ReDroid througth VNC or scrcpy / sndcpy or WebRTC (Panned) or adb shell. ReDroid is suitable for Cloud Gaming, VDI / VMI (Virtual Mobile Infurstrure), Automation Test and more.

+ https://github.com/Genymobile/scrcpy
  + display and control of Android devices connected on USB (or over TCP/IP). It does not require any root access
+ https://github.com/rom1v/sndcpy
  + forwards audio from an Android 10 device to the computer. It does not require any root access.
+ https://github.com/Genymobile/gnirehtet
  + reverse tethering over adb for Android: it allows devices to use the internet connection of the computer they are plugged on. It does not require any root access
