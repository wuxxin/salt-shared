{% if grains['os'] == 'Ubuntu' %}
include:
  - .ppa
{% endif %}

nodejs:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: nodejs_ppa
{% endif %}

npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


