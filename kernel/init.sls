{% from "kernel/defaults.jinja" import settings with context %}

{% if settings.keep_current|d(false) or grains['virtual'] == 'LXC' %}
include:
  - kernel.running

{% else %}

  {%- if grains['virtual'] != "physical" %}
    {%- set flavor='virtual' %}
  {%- else %}
    {%- set flavor='generic' %}
  {%- endif %}

linux-image:
  pkg.installed:
    - pkgs:
      - {{ settings.package.meta|replace('generic', flavor) }}
      - {{ settings.package.image|replace('generic', flavor) }}
  {% if settings.virtual_extra|d(true) %}
      - {{ settings.package.virtual_extra|replace('generic', flavor) }}
  {%- endif %}
      - {{ settings.package.tools|replace('generic', flavor) }}
      - {{ settings.package.headers|replace('generic', flavor) }}
{%- endif %}
