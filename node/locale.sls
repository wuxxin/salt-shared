{% from "node/defaults.jinja" import settings with context %}

{% set additional_list=
  settings.locale.additional_lang.strip().split(' ')|join('.UTF-8 ') ~ '.UTF-8' %}

/etc/locale.conf:
  file.managed:
    - contents: |
        LANG={{ settings.locale.lang }}
        LANGUAGE={{ settings.locale.language }}
{%- if settings.locale.messages %}
        LC_MESSAGES={{ settings.locale.messages }}
{%- endif %}

locales:
  pkg.installed:
    - pkgs:
    {% if grains['os_family'] == "Debian" %}
      - locales
    {% elif grains['os_family'] == "Arch" %}
      - glibc-locales
    {% endif %}

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
    - name: locale-gen {{ settings.locale.lang }} {{ additional_list }}
    - unless: |
        all_locales=$(locale -a | sed -r "s/\.utf8/.UTF-8/g")
        all_valid=true
        for l in {{ settings.locale.lang }} {{ additional_list }}; do
            if ! $(echo "$all_locales" | grep -q "$l"); then
                all_valid=false
            fi
        done
        $all_valid
    - require:
      - file: /etc/locale.conf
      - pkg: locales
