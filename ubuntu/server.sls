{% from "ubuntu/defaults.jinja" import settings with context %}

include:
  - ubuntu.snapd
  - ubuntu.telemetry
  - ubuntu.update
{%- if settings.backports %}
  - ubuntu.backports
{%- endif %}

ubuntu_server_nop:
  test:
    - nop
