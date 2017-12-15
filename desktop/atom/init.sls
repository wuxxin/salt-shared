include:
  - desktop.code
  - desktop.spellcheck

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("webupd8team_atom", "webupd8team/atom", 
  require_in= "pkg: atom") }}
{% endif %}

atom:
  pkg.latest:
    - require:
      - sls: desktop.code
      - sls: desktop.spellcheck
