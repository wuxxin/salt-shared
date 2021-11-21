# android.emulator.lib

Create and launch an android emulator container based on qemu/kvm for emulation.

+ Source: https://github.com/google/android-emulator-container-scripts

## Usage

+ android/emulator/lib.sls
  + `emulator_image()`
  + `emulator_desktop(profile_definition)`
  + `emulator_headless_service(profile_definition)`
  + `emulator_webrtc_service(profile_definition)`

+ Profile Definition

```yaml
environment:
  AVD_CONFIG: be appended to avd config file
  # https://developer.android.com/studio/run/emulator-commandline
  EMULATOR_PARAMS: be used instead of defaults
  ADD_EMULATOR_PARAMS: additional emulator options, eg "-camera-front webcam1"
desktop:
  template: default*|host
  options:
    # x11docker options
    - "--group-add kvm"
    - additional x11docker options. eg. "--webcam"
options:
  # podman options
  - "--device /dev/kvm"
  - additional podman options
```

### Example

```jinja
include:
  - android.emulator

{% from "android/emulator/lib.sls" import emulator_image, emulator_desktop %}
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
