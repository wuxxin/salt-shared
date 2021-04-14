{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("asciinema_ppa", "zanchey/asciinema", require_in= "pkg: asciinema") }}
{% endif %}

asciinema:
  pkg.installed:
    - pkgs:
      - asciinema
