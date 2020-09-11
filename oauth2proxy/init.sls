{% from "oauth2proxy/defaults.jinja" import settings with context %}
{% set local_binary = "/usr/local/bin/oauth2-proxy" %}
{% set external = settings.external.oauth2_proxy_tar_gz %}

oauth2proxy_archive:
  file.managed:
    - source: {{ external.download }}
    - hash: {{ external.hash }}
    - name: {{ external.target }}
  archive.extracted:
    - source: {{ external.target }}
    - dest: {{ local_binary }}
