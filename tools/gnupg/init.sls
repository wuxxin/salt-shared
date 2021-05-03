gnupg:
  pkg.installed:
    - pkgs:
      - gnupg
{% if grains['os'] == 'Ubuntu' %}
  {%- if grains['osmajorrelease']|int < 18 %}
      - gnupg-agent
  {%- endif %}
{%- endif %}

/usr/local/bin/gpgutils.py:
  file.managed:
    - source: salt://tools/gnupg/gpgutils.py
    - mode: "0755"
