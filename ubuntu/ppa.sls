{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("jayatana-ppa", "danjaredg/jayatana") }}

{% endif %} 

jayatana_nop:
  test:
    - nop
