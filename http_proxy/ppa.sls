{% if (grains['lsb_distrib_codename'] == "trusty") %}

include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("polipo_ppa", "phraktle/backports") }}

{% endif %}

polipo_nop:
  test:
    - nop
