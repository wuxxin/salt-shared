{% from "ubuntu/init.sls" import apt_add_repository %}
{% if grains['lsb_distrib_codename'] != 'eoan' and
      grains['osrelease_info'][0]|int < 20 %}
{{ apt_add_repository("wireguard_ppa",  "wireguard/wireguard", require_in= "pkg: wireguard") }}
{% endif %}

wireguard:
  pkg:
    - installed
