{% from "kernel/settings.jinja" import settings with context %}

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
