{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("webupd8team_atom", "webupd8team/atom") }}

{% endif %}

atom_ppa:
  test:
    - nop
