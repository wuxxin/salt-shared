include:
  - .ppa

nginx:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: nginx_ppa
{% endif %}

