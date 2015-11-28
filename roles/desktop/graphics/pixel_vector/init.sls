include:
  - .ppa

pixel_vector:
  pkg.installed:
    - pkgs:
      - pencil
      
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: inkscape-ppa
{% endif %}
