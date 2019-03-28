{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("inkscape-ppa", 
  "inkscape.dev/stable-daily", require_in= "pkg: vector") }}
{% endif %} 

vector:
  pkg.installed:
    - pkgs:
      - inkscape
      - librsvg2-bin

pixel_vector:
  pkg.installed:
    - pkgs:
      - pencil2d
