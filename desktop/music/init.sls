{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("sonic-pi-ppa", 
  "sonic-pi/ppa", require_in= "pkg: sonic-pi") }}
{% endif %}

sonic-pi:
  pkg.installed:
    - pkgs:
      - sonic-pi
