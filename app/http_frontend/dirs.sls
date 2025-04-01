{% from "app/http_frontend/defaults.jinja" import settings with context %}

{{ settings.ssl.base_dir }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
