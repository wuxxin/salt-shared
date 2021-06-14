{% from "android/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}

include:
  - android.tools
  - containers

{# download android lineage image builder container image #}
{{ image(settings.builder.image, settings.builder.tag) }}
