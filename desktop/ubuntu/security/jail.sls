{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("firejail_ppa", "deki/firejail", require_in= "pkg: firejail") }}
{% endif %}

firejail:
  pkg.installed:
    - pkgs:
      - firejail
