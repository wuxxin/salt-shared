{% from "node/defaults.jinja" import settings with context %}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG={{ settings.locale.lang_env }}
        LANGUAGE={{ settings.locale.language }}
{%- if settings.locale.messages_env %}
        LC_MESSAGES={{ settings.locale.messages_env }}
{%- endif %}

locales:
  pkg:
    - installed

set_system_timezone:
  timezone.system:
    - name: {{ settings.locale.timezone }}
    - utc: True

set_locale:
  cmd.wait:
    - name: locale-gen {{ settings.locale.lang_all|trim() }}
    - watch:
      - file: /etc/default/locale
    - require:
      - pkg: locales
