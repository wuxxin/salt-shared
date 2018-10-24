{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_ppa", 
  "mozillateam/ppa", require_in= "pkg: thunderbird") }}
{% endif %}

thunderbird:
  pkg.installed:
    - pkgs:
      - thunderbird
      - thunderbird-gnome-support
