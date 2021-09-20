{% from "http_frontend/defaults.jinja" import settings with context %}

{{ settings.ssl.basedir }}:
  file.directory:
    - makedirs: true
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
