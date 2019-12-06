{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_thunderbird_beta_ppa", 
  "mozillateam/thunderbird-next", require_in= "pkg: thunderbird") }}
{% endif %}

thunderbird:
  pkg.installed:
    - pkgs:
      - thunderbird
      - thunderbird-gnome-support
