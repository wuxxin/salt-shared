{% from "app/homeassistant/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import compose with context %}

{# include pipewire and gstreamer for localhost video/audio output possibilities #}
include:
  - desktop.multimedia.pipewire
  - desktop.multimedia.gstreamer
  - containers
  # - postgresql

{{ compose(settings.compose) }}
