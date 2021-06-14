# Android

## android.tools

+ adb: Android Debug Bridge
+ fastboot: flashing an Android device, boot an Android device to fastboot mode
+ aapt: Android Asset Packaging Tool

## android.scrcpy (user tool)

+ scrcpy: display and control of Android devices connected on USB (or over TCP/IP)

## android.builder.lib

### Cross-build an android lineage version for a set of target hardware

+ build_image()

#### Configure

environment:
  BUILD_DATA_VOLUME: android-build-data
  BRANCH_NAME: lineage-17.1
  DEVICE_LIST: sailfish
  SIGN_BUILDS: true
  SIGNATURE_SPOOFING: restricted
  CUSTOM_PACKAGES: |
    GmsCore GsfProxy FakeStore MozillaNlpBackend NominatimNlpBackend
    com.google.android.maps.jar FDroid FDroidPrivilegedExtension

## android.emulator.lib

### Create and launch an android emulator (using qemu for emulation) as a container

+ emulator_image()
+ emulator_desktop()
+ emulator_headless_service()
+ emulator_webrtc_service()

#### Configure

environment:
  ANDROID_DATA_VOLUME: name-of-instance-data-volume
  AVD_CONFIG: be used instead of default_args:avd if not empty
  EMULATOR_PARAMS: be used instead of default_args:emulator if not empty
  ADD_EMULATOR_PARAMS: additional emulator args, eg "-camera-front webcam1 -netdelay umts -netspeed hsdpa "
  # for launch parameter of emulator see https://developer.android.com/studio/run/emulator-commandline
desktop:
  template: default*|host
  options:
    - "--group-add kvm"
    - additional x11docker options. eg. "--webcam"
options:
  - "--device /dev/kvm"
  - additional podman options

#### Example

```jinja
{% from "android/emulator/lib.sls" import emulator_image, emulator_desktop %}
include:
  - android.emulator

{% load_yaml as android4me %}
name: android4me
environment:
  ANDROID_DATA_VOLUME: android4me_data
  ADD_EMULATOR_PARAMS: "-netdelay umts -netspeed hsdpa -camera-front webcam1"
desktop:
  options:
    - "--group-add kvm"
    - "--webcam"
{% endload %}

{{ emulator_image() }}
{{ emulator_desktop(android4me) }}
```

## android.redroid.lib

### Create and launch a (same kernel) android container using ReDroid

+ redroid_service()

+ https://github.com/remote-android/redroid-doc
  + ReDroid (Remote Android) is a GPU accelerated AIC (Android In Container) solution. You can boot many instances in Linux host or any Linux container envrionments (Docker, K8S, LXC etc.). ReDroid supports both arm64 and amd64 architectures. You can connect to ReDroid througth VNC or scrcpy / sndcpy or WebRTC (Panned) or adb shell. ReDroid is suitable for Cloud Gaming, VDI / VMI (Virtual Mobile Infurstrure), Automation Test and more.
+ https://github.com/Genymobile/scrcpy
  + display and control of Android devices connected on USB (or over TCP/IP). It does not require any root access
+ https://github.com/rom1v/sndcpy
  + forwards audio from an Android 10 device to the computer. It does not require any root access.
+ https://github.com/Genymobile/gnirehtet
  + reverse tethering over adb for Android: it allows devices to use the internet connection of the computer they are plugged on. It does not require any root access

### unsorted
```sh
  x11docker \
  --verbose --podman --cap-default \
  --hostdisplay --clipboard --gpu --hostipc --group-add kvm \
  --webcam -- \
  -e EMULATOR_PARAMS="-gpu swiftshader_indirect -accel on -no-boot-anim -memory 2048 -camera-front webcam1" \
  -e ADBKEY="$(cat ~/.android/adbkey)" \
  -e NO_FORWARD_LOGGERS=true \
  -e NO_PULSE_AUDIO=true \
  -e "AVD_CONFIG=disk.dataPartition.size = 768m" \
  --volume android-emulator:/android-home \
  --device /dev/kvm \
  --publish 8554:8554/tcp  \
  --publish 5555:5555/tcp \
  -- \
  localhost/android-emulator:latest
```
