include:
  - .ppa

ansible:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: ansible_ppa
{% endif %}
