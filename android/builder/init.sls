{% from "android/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import image with context %}

include:
  - android.tools
  - containers

{# download android lineage image builder container image #}
{{ image(settings.builder.image, settings.builder.tag) }}
