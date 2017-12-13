include:
  - .ppa

vector:
  pkg.installed:
    - pkgs:
      - inkscape
      - librsvg2-bin
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: inkscape-ppa
{% endif %}

pixel_vector:
  pkg.installed:
    - pkgs:
      - pencil