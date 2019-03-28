{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("kivy-ppa", 
  "kivy-team/kivy", require_in= "pkg: kivy") }}
{% endif %} 

kivy:
  pkg:
    - installed
