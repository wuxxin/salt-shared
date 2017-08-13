include:
  - .ppa

forman:
  pkg:
    - installed
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkgrepo: forman_ppa
{% endif %}
