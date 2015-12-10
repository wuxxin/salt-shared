{% from "kernel/defaults.jinja" import settings as s with context %}

{% if grains['lsb_distrib_codename'] in ['trusty', 'rafaela', 'romeo'] %}

linux-image:
  pkg.installed:
    - pkgs:
{%- if grains['virtual'] == "physical" %}
      - {{ s.hardware }}
{%- endif %}
      - {{ s.virtual }}
      - {{ s.tools }}

{% endif %}
