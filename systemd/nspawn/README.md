# systemd nspawn machine container

+ see [nspawn-config.md](nspawn-config.md) for config possibilities

## usage

+ create image, start machine

```
include:
  - systemd.nspawn

{% from "systemd/nspawn/lib.sls" import volume, image, machine %}

# make mkosi focal image
{{ image(name='focal', template='focal') }}

# create test machine
{% load_yaml as definition %}
name: mytest
image: focal
{% endload %}
{{ machine(definition) }}

```
