{% if grains['os'] == 'Ubuntu' %}
{% if grains['osrelease_info'][0]|int < 18 %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("ddcutil_ppa",
  "rockowitz/ddcutil", require_in= "pkg: ddcutil") }}
{% endif %}
{% endif %}

ddcutil:
  pkg.installed:
    - pkgs:
      - ddcutil
