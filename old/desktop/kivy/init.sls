{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("kivy_ppa", "kivy-team/kivy", require_in= "pkg: kivy") }}
{% endif %}

kivy:
  pkg:
    - installed
