{% from "kernel/defaults.jinja" import settings with context %}

{% if settings.manual_download|d(false) %}

linux-image:
  pkg.installed:
    - sources:
  {%- if grains['virtual'] == "physical" %}
      - {{ settings.hardware.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.hardware }}
  {%- else %}
      - {{ settings.virtual.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.virtual }}
  {%- endif %}
  {%- if settings.headers is string %}
      - {{ settings.headers.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.headers }}
  {%- else %}
    {%- for header in settings.headers %}
      - {{ header.split('_')[0] }}: {{ settings.manual_download }}/{{ header }}
    {%- endfor %}
  {%- endif %}
  {%- if settings.tools %}
      - {{ settings.tools.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.tools }}
  {%- else %}
  
linux-image-default-tools:
  pkg.installed:
    - pkgs:
      - {{ settings.default_tools}}
  {%- endif %}
      

{% else %}

linux-image:
  pkg.installed:
    - pkgs:
  {%- if grains['virtual'] == "physical" %}
      - {{ settings.hardware }}
  {%- else %}
      - {{ settings.virtual }}
  {%- endif %}
      - {{ settings.tools }}
      - {{ settings.headers }}
{%- endif %}
