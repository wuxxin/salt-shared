include:
  - .ppa

nginx:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: nginx_ppa
{% endif %}

