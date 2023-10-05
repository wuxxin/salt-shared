{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("freecad_ppa", "freecad-maintainers/freecad-stable", require_in= "pkg: freecad") }}
{% endif %}

freecad:
  pkg.installed:
    - pkgs:
      - freecad
      - netgen
      
