{% if grains['os'] == 'Ubuntu' %}
{% if grains['osrelease_info'][0]|int <= 19 %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("sonic-pi-ppa", 
  "sonic-pi/ppa", require_in= "pkg: sonic-pi") }}
{% endif %}
{% endif %}

sonic-pi:
  pkg.installed:
    - pkgs:
      - sonic-pi
