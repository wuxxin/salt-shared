{% from "http_frontend/defaults.jinja" import settings with context %}

{{ settings.cert_dir }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.cert_user }}
    - group: {{ settings.cert_user }}
