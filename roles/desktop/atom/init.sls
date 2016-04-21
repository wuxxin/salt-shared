include:
  - roles.desktop.text
  - .ppa

atom:
  pkg.latest:
    - require:
      - cmd: webupd8team_atom

{#

{% set atomversion= "1.4.0-beta3"%}
{% set actversion= salt['pkg.version']('atom') %}
{% if actversion == "" %}
  {% set newer_or_equal= 1 %}
{% else %}
  {% set newer_or_equal= salt['pkg.version_cmp'](atomversion, actversion) %}
{% endif %}

{% if newer_or_equal <= -1 %}
  {% set atomversion= actversion %}
{% endif %}

{% if actversion != "" and newer_or_equal >= 1 %}
atom_remove:
  pkg.removed:
    - name: atom
{% endif %}

atom:
  pkg.installed:
    - sources:
      - atom: https://github.com/atom/atom/releases/download/v{{ atomversion }}/atom-amd64.deb

#}
