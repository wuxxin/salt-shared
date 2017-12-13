include:
  - java.browser

pcscd-prereq:
  pkg.installed:
    - pkgs:
      - pcsc-tools
      - libccid
      - fxcyberjack
{%- if grains['lsb_distrib_codename'] == 'trusty' %}
      - libifd-cyberjack6
{%- else %}
      - libifd-cyberjack6v5
{% endif %}

pcscd:
  pkg.installed:
    - require:
      - pkg: pcscd-prereq
