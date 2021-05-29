# systemd nspawn machine container

+ see [nspawn-config.md](nspawn-config.md) for config details of nspawn machine

## usage

+ create image, start test machine

```
include:
  - systemd.nspawn

{% from "systemd/nspawn/lib.sls" import volume, image, machine %}

# make mkosi focal image
{{ image(name='focal', template=focal) }}

# create test machine
{{ machine(name ) }}

```
