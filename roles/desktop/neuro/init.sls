include:
  - .ppa

opensesam:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: cogscinl_ppa
{% endif %}

