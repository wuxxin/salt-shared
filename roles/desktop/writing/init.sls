include:
  - roles/desktop/neuro.ppa
  - .doconce

zotero:
  pkg.installed:
    - pkg: zotero-standalone
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: cogscinl_ppa
{% endif %}

