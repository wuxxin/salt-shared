# android.emulator.lib

## Create and launch an android emulator container based on qemu/kvm for emulation

+ https://github.com/google/android-emulator-container-scripts

+ `emulator_image()`
+ `emulator_desktop()`
+ `emulator_headless_service()`
+ `emulator_webrtc_service()`

### Configure

```yaml
environment:
  AVD_CONFIG: be appended to avd config file
  EMULATOR_PARAMS: be used instead of defaults
  ADD_EMULATOR_PARAMS: add emulator args, eg "-camera-front webcam1 -netdelay umts -netspeed hsdpa "
  # emulator launch parameter: https://developer.android.com/studio/run/emulator-commandline
  # -accel on
  # -no-boot-anim
  # -gpu swiftshader_indirect
  # -memory 2048
  # -netdelay umts
  # -netspeed hsdpa
  # -no-snapshot
  # -verbose
  # -camera-front webcam1
desktop:
  template: default*|host
  options:
    - "--group-add kvm"
    - additional x11docker options. eg. "--webcam"
options:
  - "--device /dev/kvm"
  - additional podman options
```

### Example

```jinja
{% from "android/emulator/lib.sls" import emulator_image, emulator_desktop %}
include:
  - android.emulator

{% load_yaml as android4me %}
name: android4me
environment:
  ADD_EMULATOR_PARAMS: "-netdelay umts -netspeed hsdpa -camera-front webcam1"
desktop:
  options:
    - "--group-add kvm"
    - "--webcam"
{% endload %}

{{ emulator_image() }}
{{ emulator_desktop(android4me) }}
```


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
