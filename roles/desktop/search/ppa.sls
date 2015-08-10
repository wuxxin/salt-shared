{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("recoll_ppa", "recoll-backports/recoll-1.15-on") }}

{% endif %}

