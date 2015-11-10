{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("sao_backports_ppa", "sao/backports") }}

{% endif %}
