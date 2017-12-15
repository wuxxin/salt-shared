include:
  - desktop.neuro.ppa

zotero:
  pkg.installed:
    - pkg: zotero-standalone
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: cogscinl_ppa
{% endif %}

