{% from "kernel/defaults.jinja" import settings with context %}

{% if settings.keep_current|d(false) %}
linux-image:
  pkg.installed:
    - pkgs:
      - linux-tools-{{ grains['kernelrelease'] }}
  
{% else %}

linux-image:
  pkg.installed:
    - pkgs:
  {%- if grains['virtual'] == 'LXC' %}
    {# take linux version from host kernel on lxc/lxd #}
      - linux-tools-{{ grains['kernelrelease'] }}
  {%- else %}
    {%- if grains['virtual'] != "physical" %}
      {%- set flavor='virtual' %}
    {%- else %}
      {%- set flavor='generic' %}
    {%- endif %}
      - {{ settings.meta|replace('generic', flavor) }}
      - {{ settings.image|replace('generic', flavor) }}
    {% if settings.virtual_extra|d(true) %}
      - {{ settings.virtual_extra|replace('generic', flavor) }}
    {%- endif %}
      - {{ settings.tools|replace('generic', flavor) }}
      - {{ settings.headers|replace('generic', flavor) }}
  {%- endif %}
{%- endif %}
