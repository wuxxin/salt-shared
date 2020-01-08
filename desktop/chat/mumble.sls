{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mumble_ppa", 
  "mumble/release", require_in= "pkg: mumble") }}
{% endif %}

mumble:
  pkg:
    - installed
