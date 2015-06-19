{% set atomversion= "0.210.0"%}
{% set actversion= salt['aptpkg.version']('atom') %}

{% if actversion == "" or salt['aptpkg.version_cmp'](atomversion, actversion) >= 1 %}

  {% if actversion != "" %}
atom_remove:
  pkg.removed:
    - name: atom
  {% endif %}

atom:
  pkg.install:
    - sources:
      - atom: https://github.com/atom/atom/releases/download/v{{ atomversion }}/atom-amd64.deb

{% endif %}
