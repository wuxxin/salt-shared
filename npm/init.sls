{% if grains['os'] == 'Ubuntu' %}
include:
  - .ppa
{% endif %}

nodejs:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: ppa-nodejs
{% endif %}

npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


