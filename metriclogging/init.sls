{% from "app/metriclogging/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import compose with context %}

include:
  - containers


{{ compose(settings.compose.gui) }}
{{ compose(settings.compose.metric) }}
{{ compose(settings.compose.exporter) }}
{{ compose(settings.compose.logging) }}
