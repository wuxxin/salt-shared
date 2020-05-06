{# XXX deprecated, use state: locale #}
{% from "locale/defaults.jinja" import settings with context %}
{% set timezone=salt['pillar.get']('timezone', settings.timezone) %}
{# XXX compatibility: use locale/defaults if pillar:timezone is not set #}
SystemTimezone:
  timezone.system:
    - name: {{ timezone }}
    - utc: True
