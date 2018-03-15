{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("firejail-ppa", "deki/firejail", require_in= "pkg: firejail") }}
{% endif %} 

firejail:
  pkg.installed:
    - pkgs:
      - firejail
