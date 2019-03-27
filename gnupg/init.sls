gnupg:
  pkg.installed:
    - pkgs:
      - gnupg
{%- if grains['osmajorrelease']|int < 18 %}
      - gnupg-agent
{%- endif %}

/usr/local/bin/gpgutils.py:
  file.managed:
    - source: salt://gnupg/gpgutils.py
    - mode: "0755"
