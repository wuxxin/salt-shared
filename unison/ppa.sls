{% if (grains['os'] == 'Ubuntu') %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}

{% if grains['lsb_distrib_codename']  == 'xenial' %}
  {{ apt_add_repository("john_freeman_unison_ppa", "john-freeman/unison ") }}
{% elif grains['lsb_distrib_codename'] == 'trusty' %}
  {{ apt_add_repository("sao_backports_ppa", "sao/backports") }}
{% endif %}

{% endif %}
