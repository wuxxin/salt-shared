include:
  - roles/desktop/neuro.ppa

zotero:
  pkg.installed:
    - pkg: zotero-standalone
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: cogscinl_ppa
{% endif %}

