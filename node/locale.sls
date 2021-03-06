{% from "node/defaults.jinja" import settings with context %}

{% set additional= settings.locale.additional.strip().split(' ')|join('.UTF-8 ') ~ '.UTF-8' %}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG={{ settings.locale.lang }}
        LANGUAGE={{ settings.locale.language }}
{%- if settings.locale.messages %}
        LC_MESSAGES={{ settings.locale.messages }}
{%- endif %}

locales:
  pkg:
    - installed

tzdata:
  pkg:
    - installed

set_system_timezone:
  timezone.system:
    - name: {{ settings.locale.timezone }}
    - utc: True
    - require:
      - pkg: tzdata

generate_locale:
  cmd.run:
    - name: locale-gen {{ settings.locale.lang }} {{ additional }}
    - unless: |
        all_locales=$(locale -a | sed -r "s/\.utf8/.UTF-8/g")
        all_valid=true
        for l in {{ settings.locale.lang }} {{ additional }}; do
            if ! $(echo "$all_locales" | grep -q "$l"); then
                all_valid=false
            fi
        done
        $all_valid
    - require:
      - file: /etc/default/locale
      - pkg: locales
