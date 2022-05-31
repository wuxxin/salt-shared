{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.python

development_tools:
  pkg.installed:
    - pkgs:
      ## conversion
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc
      - pandoc-crossref
      ## encryption
      # age - simple, modern and secure file encryption tool
      - age
      ## updates
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

{% load_yaml as pkgs %}
      ## devop tools
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # butane - Human readable Butane Configs into machine readable Ignition Configs
      - butane
{% endload %}
{{ pamac_install("development_tools_aur", pkgs) }}
