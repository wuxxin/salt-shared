{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %} 


{% if grains['os'] == 'Ubuntu' %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("recoll_ppa", "recoll-backports/recoll-1.15-on") }}

{% endif %}

recoll_nop:
  test:
    - nop
