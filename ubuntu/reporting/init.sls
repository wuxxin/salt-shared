{% from "ubuntu/defaults.jinja" import settings with context %}

include:
{%- if settings.reporting %}
  - ubuntu.reporting.enabled
{%- else %}
  - ubuntu.reporting.disabled
{%- endif %}

reporting_configure:
  test:
    - nop
    - require:
{%- if settings.reporting %}
      - sls: ubuntu.reporting.enabled
{%- else %}
      - sls: ubuntu.reporting.disabled
{%- endif %}
