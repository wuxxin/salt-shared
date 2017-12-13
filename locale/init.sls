{% from "locale/defaults.jinja" import settings as s with context %}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG={{ s.lang }}_{{ s.country|upper }}.UTF-8
        LANGUAGE={{ s.lang }}_{{ s.country|upper }}:{{ s.lang }}
        LC_MESSAGES=POSIX

locales:
  pkg:
    - installed

{% set addlist = "" %}
{% for x in s.additional.split(' ') %}
{% set l = x.split(':')[0] %}
{% set c = x.split(':')[1] %}
{% set tobeadded = l+ '_'+ c|upper()+ '.UTF-8' %}
{% set newlist = addlist+ ' '+ tobeadded %}
{% set addlist = newlist %}
{% set dummy = s.__setitem__('additional_list', addlist) %}
{% endfor %}

set_locale:
  cmd.wait:
    - name: locale-gen {{ s.lang }}_{{ s.country|upper }}.UTF-8 {{ s.additional_list|trim() }}
    - watch:
      - file: /etc/default/locale
    - require:
      - pkg: locales

