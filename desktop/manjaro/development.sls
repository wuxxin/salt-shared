{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.python

desktop_manjaro_dev_packages:
  pkg.installed:
    - pkgs:
      # age - simple, modern and secure file encryption tool
      - age
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

{% load_yaml as pkgs %}
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
{% endload %}
{{ pamac_install("desktop_manjaro_dev_aur_packages", pkgs) }}
