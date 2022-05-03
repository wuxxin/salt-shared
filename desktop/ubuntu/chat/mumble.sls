{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("mumble_ppa", "mumble/release", require_in= "pkg: mumble") }}
{% endif %}

mumble:
  pkg:
    - installed

/usr/local/bin/mumble_ping.py:
  file.managed:
    - source: salt://desktop/ubuntu/chat/mumble_ping.py
    - mode: 0755
