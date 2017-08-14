{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("cogscinl_ppa", "smathot/cogscinl") }}

{% endif %}

cogscinl_nop:
  test:
    - nop
