{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("wireguard_ppa",  "wireguard/wireguard", require_in= "pkg: wireguard") }}
{% endif %}

wireguard:
  pkg:
    - installed
