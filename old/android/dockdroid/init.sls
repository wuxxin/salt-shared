{% from "android/dockdroid/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import image with context %}

include:
  - android.tools
  - containers

{# download android container image #}
{{ image(settings.container.image, settings.container.tag) }}
