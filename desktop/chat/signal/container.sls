{% from "containers/signal/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}

include:
  - containers

{{ container(settings) }}

sudo x11docker --podman --cap-default --hostdisplay --gpu --webcam --pulseaudio \
  --dbus --clipboard -- \
  localhost/signal-desktop
