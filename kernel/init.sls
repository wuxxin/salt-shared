{% from "kernel/defaults.jinja" import settings with context %}

{% if settings.manual_download|d(false) %}

linux-image:
  pkg.installed:
    - sources:
  {%- if grains['virtual'] == "physical" %}
    {%- if salt['pkg.version'](settings.hardware.split('_')[0]) == '' %}
      - {{ settings.hardware.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.hardware }}
    {%- endif %}
  {%- else %}
    {%- if salt['pkg.version'](settings.virtual.split('_')[0]) == '' %}
      - {{ settings.virtual.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.virtual }}
    {%- endif %}
  {%- endif %}
  {%- if settings.headers is string %}
    {%- if salt['pkg.version'](settings.headers.split('_')[0]) == '' %}
      - {{ settings.headers.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.headers }}
    {%- endif %}
  {%- else %}
    {%- for header in settings.headers %}
      {%- if salt['pkg.version'](header.split('_')[0]) == '' %}
      - {{ header.split('_')[0] }}: {{ settings.manual_download }}/{{ header }}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
  {%- if settings.tools %}
    {%- if salt['pkg.version'](settings.tools.split('_')[0]) == '' %}
      - {{ settings.tools.split('_')[0] }}: {{ settings.manual_download }}/{{ settings.tools }}
    {%- endif %}
  {%- else %}
  
linux-image-default-tools:
  pkg.installed:
    - pkgs:
      - {{ settings.default_tools}}
  {%- endif %}
      

{% elif settings.keep_current|d(false) %}
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
    {%- if grains['virtual'] == "physical" %}
      - {{ settings.hardware }}
    {%- else %}
      - {{ settings.virtual }}
    {%- endif %}
      - {{ settings.tools }}
      - {{ settings.headers }}
  {%- endif %}
{%- endif %}
