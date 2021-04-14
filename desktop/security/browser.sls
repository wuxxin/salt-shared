{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("torbrowser_ppa", "micahflee/ppa",
  require_in = "pkg: torbrowser-launcher") }}
{% endif %}

torbrowser-launcher:
  pkg:
    - installed
