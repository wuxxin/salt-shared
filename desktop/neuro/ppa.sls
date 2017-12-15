{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("cogscinl_ppa", "smathot/cogscinl") }}
{% endif %}

desktop_neuro_nop:
  test:
    - nop
