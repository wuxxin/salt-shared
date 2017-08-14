{% if grains['os'] == 'Ubuntu' %}
include:
  - .ppa
{% endif %}

nodejs:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: nodejs_ppa
{% endif %}

npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


