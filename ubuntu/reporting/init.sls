{% from "ubuntu/defaults.jinja" import settings with context %}

include:
{% if settings.reporting %}
  - ubuntu.reporting.enabled
{% else %}
  - ubuntu.reporting.disabled
{% endif %}
