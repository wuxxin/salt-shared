# systemd nspawn machine container

+ see [nspawn-config.md](nspawn-config.md) for config possibilities

## usage

+ create image, start machine

```jinja
include:
  - systemd.nspawn

{% from "systemd/nspawn/lib.sls" import volume, image, machine %}

# make mkosi focal image
{{ image(name='focal', template='focal') }}

# create test machine
{% load_yaml as definition %}

# mandatory: name, image
# name: name of the nspawn container and name of the controlling systemd service
name: testmachine
# image: a image name created with eg. `image(name='focal', template='focal')`
image: focal

# enabled: if false, service will not get started and will be stopped if running
enabled: true

# environment: dict of key,value pairs to be included in the target environment
environment: {}

# after creation of machine, a script and authorized_keys can be copied and executed
postinst:
  # default ssh keys string authorized for root and <userid>
  # will be created at /tmp/authorized_keys for usage in postinst
  authorized_keys: ""

# additional or overriding nspawn settings
nspawn:
  Exec: {}
  Files: {}
  Network: {}
{% endload %}
{{ machine(definition) }}

```
