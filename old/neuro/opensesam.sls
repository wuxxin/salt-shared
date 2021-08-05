{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("cogscinl_ppa", "smathot/cogscinl", require_in= "pkg: opensesam") }}

opensesam:
  pkg:
    - installed

{% endif %}
