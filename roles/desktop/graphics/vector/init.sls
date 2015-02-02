include:
  - .ppa

vector:
  pkg.installed:
    - pkgs:
      - inkscape
      - librsvg2-bin
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: inkscape-ppa
{% endif %}

