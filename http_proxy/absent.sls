{% from "http_proxy/defaults.jinja" import settings with context %}

include:
  - .client_no_proxy

trafficserver:
  service:
    - dead
  pkg:
    - removed

{{ settings.cache_dir }}:
  file:
    - absent
