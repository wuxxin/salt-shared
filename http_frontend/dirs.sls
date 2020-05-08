{% from "http_frontend/defaults.jinja" import settings with context %}

{{ settings.cert_dir }}:
  file:
    - directory
