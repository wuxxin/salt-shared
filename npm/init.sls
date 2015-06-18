{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - .ppa
{% endif %}

nodejs:
  pkg.installed:
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: nodejs_ppa
{% endif %}

npm:
  pkg:
    - installed
    - require:
      - pkg: nodejs


