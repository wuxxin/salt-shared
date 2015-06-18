include:
  - .ppa

opensesam:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: cogscinl_ppa
{% endif %}

