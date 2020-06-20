{% from "ubuntu/defaults.jinja" import settings with context %}

include:
{%- if settings.snapd %}
  - ubuntu.snapd.enabled
{%- else %}
  - ubuntu.snapd.disabled
{%- endif %}

snapd_configure:
  test:
    - nop
    - require:
{%- if settings.snapd %}
      - sls: ubuntu.snapd.enabled
{%- else %}
      - sls: ubuntu.snapd.disabled
{%- endif %}
