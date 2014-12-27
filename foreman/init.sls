include:
  - .ppa

forman:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: forman_ppa
{% endif %}
