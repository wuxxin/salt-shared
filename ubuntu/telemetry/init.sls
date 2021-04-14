{% from "ubuntu/defaults.jinja" import settings with context %}

include:
{%- if settings.telemetry %}
  - ubuntu.telemetry.enabled
{%- else %}
  - ubuntu.telemetry.disabled
{%- endif %}

telemetry_configure:
  test:
    - nop
    - require:
{%- if settings.telemetry %}
      - sls: ubuntu.telemetry.enabled
{%- else %}
      - sls: ubuntu.telemetry.disabled
{%- endif %}
