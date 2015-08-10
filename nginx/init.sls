include:
  - .ppa

nginx:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: nginx_ppa
{% endif %}

