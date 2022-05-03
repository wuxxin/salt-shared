include:
  - android.tools
{%- if grains['os'] == 'Ubuntu' %}
  - android.scrcpy
{% endif %}
