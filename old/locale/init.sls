{% from "old/locale/defaults.jinja" import settings with context %}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG={{ settings.lang }}
        LANGUAGE={{ settings.language }}
        LC_MESSAGES={{ settings.messages }}

locales:
  pkg:
    - installed

set_system_timezone:
  timezone.system:
    - name: {{ settings.timezone }}
    - utc: True

set_locale:
  cmd.wait:
    - name: locale-gen {{ settings.lang }} {{ settings.additional|trim() }}
    - watch:
      - file: /etc/default/locale
    - require:
      - pkg: locales
