include:
  - ubuntu.snapd
  - ubuntu.telemetry
  - ubuntu.update
{%- if settings.backports %}
  - ubuntu.backports
{%- endif %}
