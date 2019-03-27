include:
  - java.browser

{# lib is called libifs-cyberjack6 everywhere except on xenial #}

pcscd-prereq:
  pkg.installed:
    - pkgs:
      - pcsc-tools
      - libccid
      - fxcyberjack
{%- if grains['lsb_distrib_codename'] == 'xenial' %}
      - libifd-cyberjack6v5
{%- else %}
      - libifd-cyberjack6
{% endif %}

pcscd:
  pkg.installed:
    - require:
      - pkg: pcscd-prereq
