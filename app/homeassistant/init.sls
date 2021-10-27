{% from "app/homeassistant/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import compose with context %}

include:
  - containers
  # - postgresql

{{ compose(settings.compose) }}
