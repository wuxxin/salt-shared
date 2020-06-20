{% from "ubuntu/defaults.jinja" import settings with context %}

include:
{% if settings.snapd %}
  - ubuntu.snapd.enabled
{% else %}
  - ubuntu.snapd.disabled
{% endif %}
