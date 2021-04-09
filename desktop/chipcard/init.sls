include:
  - java.browser

{# lib is called libifs-cyberjack6 everywhere except on xenial #}

pcscd-prereq:
  pkg.installed:
    - pkgs:
      - pcsc-tools
      - libccid {# all usb smartcard reader #}
{%- if grains['oscodename'] == 'xenial' %}
      - fxcyberjack
      - libifd-cyberjack6v5
{%- else %}
      - libifd-cyberjack6
{% endif %}

pcscd:
  pkg.installed:
    - require:
      - pkg: pcscd-prereq
