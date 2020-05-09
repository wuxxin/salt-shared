{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("tlp_ppa", "linrunner/tlp", require_in= "pkg: tlp") }}
{% endif %}

tlp:
  pkg.installed:
    - pkgs:
      - tlp
      - tlp-rdw

psensor:
  pkg:
    - installed
