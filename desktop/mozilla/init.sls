{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_ppa", 
  "mozillateam/ppa", require_in= [
    "pkg: firefox", "pkg: thunderbird"]) }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox
{%- if grains['osmajorrelease']|int >= 18 and grains['osrelease'] != '18.04' %}
      - webext-ublock-origin
      - webext-umatrix
      - webext-privacy-badger
      - webext-form-history-control
{%- endif %}

thunderbird:
  pkg.installed:
    - pkgs:
      - thunderbird
      - thunderbird-gnome-support
