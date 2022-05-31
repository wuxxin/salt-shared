{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.python

development_tools:
  pkg.installed:
    - pkgs:
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc
      - pandoc-crossref
      # age - simple, modern and secure file encryption tool
      - age
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

{% load_yaml as pkgs %}
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # ttf-humor-sans - xkcd styled sans-serif typeface
      - ttf-humor-sans
{% endload %}
{{ pamac_install("development_tools_aur", pkgs) }}
