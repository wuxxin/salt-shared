{% from "http_frontend/defaults.jinja" import settings with context %}

{{ settings.ssl.pki.data }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.ssl.pki.user }}
    - group: {{ settings.ssl.pki.user }}
