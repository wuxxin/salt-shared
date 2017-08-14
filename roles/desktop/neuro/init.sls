include:
  - .ppa

opensesam:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: cogscinl_ppa
{% endif %}
