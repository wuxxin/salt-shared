{% from "app/metriclogging/defaults.jinja" import settings with context %}
{% from "app/containers/lib.sls" import compose with context %}

include:
  - app/containers


{{ compose(settings.compose.gui) }}
{{ compose(settings.compose.metric) }}
{{ compose(settings.compose.exporter) }}
{{ compose(settings.compose.logging) }}
