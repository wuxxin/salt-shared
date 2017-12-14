{% from "locale/defaults.jinja" import settings as s with context %}

{% set locale={'lang': s.lang+ '_'+ s.country|upper+ '.UTF-8',
          'language': s.lang+ '_'+ s.country|upper+ ':'+ s.lang} %}
{% if s.posix_messages %}
  {% set dummy = locale.__setitem__('messages', 'POSIX') %}
{% else %}
  {% set dummy = locale.__setitem__('messages', locale['lang']) %}
{% endif %}
{% set templist = "" %}
{% for x in s.additional.split(' ') %}
  {% set l = x.split(':')[0] %}
  {% set c = x.split(':')[1] %}
  {% set tobeadded = l+ '_'+ c|upper()+ '.UTF-8' %}
  {% set newlist = templist+ ' '+ tobeadded %}
  {% set templist = newlist %}
  {% set dummy = locale.__setitem__('additional', templist) %}
{% endfor %}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG={{ locale.lang }}
        LANGUAGE={{ locale.language }}
        LC_MESSAGES={{ locale.messages }}

locales:
  pkg:
    - installed

set_locale:
  cmd.wait:
    - name: locale-gen {{ locale.lang }} {{ locale.additional|trim() }}
    - watch:
      - file: /etc/default/locale
    - require:
      - pkg: locales

