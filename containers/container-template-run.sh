#!/usr/bin/env bash

exec x11docker \
{%- for k,v in profile.x11docker %}
  {{ k,v }}
{%- endfor %}
  -- \
{%- for k,v in profile.environment %}
  -e {{ k }}={{ v }} \
{%- endfor %}
  -- \
  localhost/android-emulator:latest
{#
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
#}
