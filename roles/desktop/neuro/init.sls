include:
  - .ppa

opensesam:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: cogscinl_ppa
{% endif %}
