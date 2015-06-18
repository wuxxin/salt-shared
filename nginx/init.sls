include:
  - .ppa

nginx:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: nginx_ppa
{% endif %}

