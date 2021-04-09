{% if grains['os'] == 'Ubuntu' %}
  {% if grains['osmajorrelease']|int < 20 and grains['oscodename'] != 'eoan' %}
      {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("wireguard_ppa",  "wireguard/wireguard", require_in= "pkg: wireguard") }}
  {% endif %}
{% endif %}

wireguard:
  pkg:
    - installed
