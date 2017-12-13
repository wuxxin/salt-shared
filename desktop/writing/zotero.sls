include:
  - desktop/neuro.ppa

zotero:
  pkg.installed:
    - pkg: zotero-standalone
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: cogscinl_ppa
{% endif %}

