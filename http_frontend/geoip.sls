{% from "http_frontend/defaults.jinja" import settings with context %}

geoip_cli:
  pkg.installed:
    - name: mmdb-bin    {# IP geolocation lookup command-line tool #}

{% if settings.geoip.enabled %}
  {% set config = settings.geoip_provider[settings.geoip.provider] %}
  {% set external = settings.external[config.external] %}

# download geoip database
geoip_database:
  file.managed:
    - name: {{ external.target }}
    - source: {{ external.download }}
    - source_hash: sha256={{ external.hash }}
  cmd.run:
  {%- if config.transform == 'gzip' %}
    - name: gzip < {{ external.target }} > {{ config.database }}
  {%- else %}
    - name: cp {{ external.target }} {{ config.database }}
  {%- endif %}
    - onchanges:
      - file: geoip_database

{% endif %}
