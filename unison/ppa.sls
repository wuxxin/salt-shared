{% if (grains['os'] == 'Ubuntu') %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}

{% if grains['lsb_distrib_codename'] in ['wily', 'xenial'] %}
  {{ apt_add_repository("john_freeman_unison_ppa", "john-freeman/unison ") }}
{% elif grains['lsb_distrib_codename'] in ['trusty', 'precise'] %}
  {{ apt_add_repository("sao_backports_ppa", "sao/backports") }}
{% endif %}

{% endif %}

unison_nop:
  test:
    - nop
